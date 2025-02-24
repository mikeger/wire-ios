//
// Wire
// Copyright (C) 2024 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import CoreData

// sourcery: AutoMockable
protocol CoreDataMessagingMigratorProtocol {
    func requiresMigration(at storeURL: URL, toVersion version: CoreDataMessagingMigrationVersion) -> Bool
    func migrateStore(at storeURL: URL, toVersion version: CoreDataMessagingMigrationVersion) throws
}

enum CoreDataMessagingMigratorError: Error {
    case missingStoreURL
    case missingFiles(message: String)
    case unknownVersion
    case migrateStoreFailed(error: Error)
    case failedToForceWALCheckpointing
    case failedToReplacePersistentStore(sourceURL: URL, targetURL: URL, underlyingError: Error)
    case failedToDestroyPersistentStore(storeURL: URL)
}

extension CoreDataMessagingMigratorError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .missingStoreURL:
            return "missingStoreURL"
        case .missingFiles(let message):
            return "missingFiles: \(message)"
        case .unknownVersion:
            return "unknownVersion"
        case .migrateStoreFailed(let error):
            let nsError = error as NSError
            return "migrateStoreFailed: \(error.localizedDescription). "
            + "NSError code: \(nsError.code) --- domain \(nsError.domain) --- userInfo: \(dump(nsError.userInfo))."
        case .failedToForceWALCheckpointing:
            return "failedToForceWALCheckpointing"
        case .failedToReplacePersistentStore(let sourceURL, let targetURL, let underlyingError):
            let nsError = underlyingError as NSError
            return "failedToReplacePersistentStore: \(underlyingError.localizedDescription). sourceURL: \(sourceURL). targetURL: \(targetURL). "
            + "NSError code: \(nsError.code) --- domain \(nsError.domain) --- userInfo: \(dump(nsError.userInfo))"
        case .failedToDestroyPersistentStore(let storeURL):
            return "failedToDestroyPersistentStore: \(storeURL)"
        }
    }
}

final class CoreDataMessagingMigrator: CoreDataMessagingMigratorProtocol {

    private let zmLog = ZMSLog(tag: "core-data")
    private let isInMemoryStore: Bool

    private var persistentStoreType: NSPersistentStore.StoreType {
        isInMemoryStore ? .inMemory : .sqlite
    }

    init(isInMemoryStore: Bool) {
        self.isInMemoryStore = isInMemoryStore
    }

    func requiresMigration(at storeURL: URL, toVersion version: CoreDataMessagingMigrationVersion) -> Bool {
        guard let metadata = try? metadataForPersistentStore(at: storeURL) else {
            return false
        }
        return compatibleVersionForStoreMetadata(metadata) != version
    }

    func migrateStore(at storeURL: URL, toVersion version: CoreDataMessagingMigrationVersion) throws {
        zmLog.safePublic(
            "migrateStore at: \(SanitizedString(stringLiteral: storeURL.absoluteString)) to version: \(SanitizedString(stringLiteral: version.rawValue))",
            level: .info
        )

        try forceWALCheckpointingForStore(at: storeURL)

        var currentURL = storeURL

        for migrationStep in try migrationStepsForStore(at: storeURL, to: version) {

            let logMessage = "messaging core data store migration step \(migrationStep.sourceVersion) to \(migrationStep.destinationVersion)"
            WireLogger.localStorage.info(logMessage, attributes: .safePublic)

            try self.runPreMigrationStep(migrationStep, for: currentURL)

            let manager = NSMigrationManager(sourceModel: migrationStep.sourceModel, destinationModel: migrationStep.destinationModel)
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)

            do {
                try manager.migrateStore(
                    from: currentURL,
                    type: persistentStoreType,
                    mapping: migrationStep.mappingModel,
                    to: destinationURL,
                    type: persistentStoreType
                )
                WireLogger.localStorage.info("finish migrate store for \(migrationStep.sourceVersion)", attributes: .safePublic)
            } catch {
                throw CoreDataMessagingMigratorError.migrateStoreFailed(error: error)
            }

            if currentURL != storeURL {
                WireLogger.localStorage.info("destroy store \(storeURL)", attributes: .safePublic)
                // Destroy intermediate step's store
                try destroyStore(at: currentURL)
            }

            currentURL = destinationURL

            WireLogger.localStorage.info("finish migration step for \(migrationStep.sourceVersion)", attributes: .safePublic)

            try self.runPostMigrationStep(migrationStep, for: currentURL)
        }
        WireLogger.localStorage.info("replace store \(storeURL), with \(currentURL)", attributes: .safePublic)
        try replaceStore(at: storeURL, withStoreAt: currentURL)
        WireLogger.localStorage.info("replace store finished", attributes: .safePublic)

        if currentURL != storeURL {
            WireLogger.localStorage.info("destroy last store \(currentURL)", attributes: .safePublic)
            try destroyStore(at: currentURL)
        }
    }

    private func migrationStepsForStore(
        at storeURL: URL,
        to destinationVersion: CoreDataMessagingMigrationVersion
    ) throws -> [CoreDataMessagingMigrationStep] {
        guard
            let metadata = try? metadataForPersistentStore(at: storeURL),
            let sourceVersion = compatibleVersionForStoreMetadata(metadata)
        else {
            throw CoreDataMessagingMigratorError.unknownVersion
        }

        return try migrationSteps(fromSourceVersion: sourceVersion, toDestinationVersion: destinationVersion)
    }

    private func migrationSteps(
        fromSourceVersion sourceVersion: CoreDataMessagingMigrationVersion,
        toDestinationVersion destinationVersion: CoreDataMessagingMigrationVersion
    ) throws -> [CoreDataMessagingMigrationStep] {
        var sourceVersion = sourceVersion
        var migrationSteps: [CoreDataMessagingMigrationStep] = []

        while sourceVersion != destinationVersion, let nextVersion = sourceVersion.nextVersion {
            let step = try CoreDataMessagingMigrationStep(sourceVersion: sourceVersion, destinationVersion: nextVersion)
            migrationSteps.append(step)

            sourceVersion = nextVersion
        }

        return migrationSteps
    }

    // MARK: - Write-Ahead Logging (WAL)

    // Taken from https://williamboles.com/progressive-core-data-migration/
    func forceWALCheckpointingForStore(at storeURL: URL) throws {
        guard
            let metadata = try? metadataForPersistentStore(at: storeURL),
            let version = compatibleVersionForStoreMetadata(metadata),
            let versionURL = version.managedObjectModelURL(),
            let model = NSManagedObjectModel(contentsOf: versionURL)
        else {
            zmLog.safePublic("skip WAL checkpointing for store", level: .info)
            return
        }

        zmLog.safePublic("force WAL checkpointing for store", level: .info)

        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = try persistentStoreCoordinator.addPersistentStore(type: persistentStoreType, at: storeURL, options: options)

            try persistentStoreCoordinator.remove(store)
            zmLog.safePublic("finish WAL checkpointing for store", level: .info)
        } catch {
            throw CoreDataMessagingMigratorError.failedToForceWALCheckpointing
        }
    }

    // MARK: - Helpers

    private func metadataForPersistentStore(at storeURL: URL) throws -> [String: Any] {
        return try NSPersistentStoreCoordinator.metadataForPersistentStore(type: persistentStoreType, at: storeURL)
    }

    private func compatibleVersionForStoreMetadata(_ metadata: [String: Any]) -> CoreDataMessagingMigrationVersion? {
        let allVersions = CoreDataMessagingMigrationVersion.allCases
        let compatibleVersion = allVersions.first {
            guard let url = $0.managedObjectModelURL() else {
                return false
            }

            let model = NSManagedObjectModel(contentsOf: url)
            return model?.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) == true
        }

        return compatibleVersion
    }

    // MARK: - NSPersistentStoreCoordinator File Managing

    private func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) throws {
        zmLog.safePublic(
            "replace store at target url: \(SanitizedString(stringLiteral: targetURL.absoluteString))",
            level: .info
        )
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.replacePersistentStore(
                at: targetURL,
                destinationOptions: nil,
                withPersistentStoreFrom: sourceURL,
                sourceOptions: nil,
                type: persistentStoreType
            )
        } catch {
            throw CoreDataMessagingMigratorError.failedToReplacePersistentStore(sourceURL: sourceURL, targetURL: targetURL, underlyingError: error)
        }
    }

    private func destroyStore(at storeURL: URL) throws {
        zmLog.safePublic(
            "destroy store of at: \(SanitizedString(stringLiteral: storeURL.absoluteString))",
            level: .info
        )

        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, type: persistentStoreType, options: nil)
        } catch {
            throw CoreDataMessagingMigratorError.failedToDestroyPersistentStore(storeURL: storeURL)
        }
    }

    // MARK: - CoreDataMigration Actions

    func runPreMigrationStep(_ step: CoreDataMessagingMigrationStep, for storeURL: URL) throws {
        guard let action = CoreDataMigrationActionFactory.createPreMigrationAction(for: step.destinationVersion) else {
            return
        }
        WireLogger.localStorage.debug("run preMigration step \(step.destinationVersion)", attributes: .safePublic)
        try action.perform(on: storeURL,
                           with: step.sourceModel)
    }

    func runPostMigrationStep(_ step: CoreDataMessagingMigrationStep, for storeURL: URL) throws {

        guard let action = CoreDataMigrationActionFactory.createPostMigrationAction(for: step.destinationVersion) else { return }

        WireLogger.localStorage.debug("run postMigration step \(step.destinationVersion)", attributes: .safePublic)
        try action.perform(on: storeURL,
                           with: step.destinationModel)
    }
}
