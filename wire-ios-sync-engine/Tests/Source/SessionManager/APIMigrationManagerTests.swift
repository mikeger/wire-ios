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

import Foundation
import WireDataModelSupport
@testable import WireSyncEngine
@testable import WireSyncEngineSupport
import WireTransport
import XCTest

class APIMigrationMock: APIMigration {
    var version: APIVersion

    init(version: APIVersion) {
        self.version = version
    }

    var performCalls = [(session: ZMUserSession, clientID: String)]()

    func perform(with session: ZMUserSession, clientID: String) async throws {
        performCalls.append((session, clientID))
    }
}

final class APIMigrationManagerTests: MessagingTest {

    // MARK: - Verifying if migration is needed

    func test_itReturnsTrue_WhenMigrationIsNeeded() async {
        // Given
        let session1 = await setupSession(with: "clientID1")
        let session2 = await setupSession(with: "clientID2")

        let migrationV1 = APIMigrationMock(version: .v1)
        let migrationV2 = APIMigrationMock(version: .v2)
        let migrationV3 = APIMigrationMock(version: .v3)

        let sut = APIMigrationManager(migrations: [
            migrationV1,
            migrationV2,
            migrationV3
        ])

        sut.persistLastUsedAPIVersion(for: session1, apiVersion: .v3)
        sut.persistLastUsedAPIVersion(for: session2, apiVersion: .v1)

        // When / Then
        XCTAssertTrue(sut.isMigration(to: .v3, neededForSessions: [session1, session2]))

        await tearDownSessions([session1, session2])
    }

    func test_itReturnsFalse_WhenMigrationIsNotNeeded() async {
        // Given
        let session1 = await setupSession(with: "clientID1")
        let session2 = await setupSession(with: "clientID2")

        let migrationV1 = APIMigrationMock(version: .v1)
        let migrationV2 = APIMigrationMock(version: .v2)

        let sut = APIMigrationManager(migrations: [
            migrationV1,
            migrationV2
        ])

        sut.persistLastUsedAPIVersion(for: session1, apiVersion: .v3)
        sut.persistLastUsedAPIVersion(for: session2, apiVersion: .v2)

        // When / Then
        XCTAssertFalse(sut.isMigration(to: .v3, neededForSessions: [session1, session2]))

        await tearDownSessions([session1, session2])
    }

    // MARK: - Migrating sessions

    func test_itPerformsMigrationsForVersionsHigherThanLastUsed() async {
        // Given
        let clientID = "123abcd"
        let userSession = await setupSession(with: clientID)

        let migrationV1 = APIMigrationMock(version: .v1)
        let migrationV2 = APIMigrationMock(version: .v2)
        let migrationV3 = APIMigrationMock(version: .v3)

        let sut = APIMigrationManager(migrations: [
            migrationV1,
            migrationV2,
            migrationV3
        ])

        sut.persistLastUsedAPIVersion(for: userSession, apiVersion: .v2)

        // When
        await sut.migrateIfNeeded(sessions: [userSession], to: .v3)

        // Then
        XCTAssertEqual(migrationV1.performCalls.count, 0)
        XCTAssertEqual(migrationV2.performCalls.count, 0)
        XCTAssertEqual(migrationV3.performCalls.count, 1)

        await tearDownSession(userSession)
    }

    func test_itPerformsMigrationsForMultipleSessions() async {
        // Given
        let clientID1 = UUID().uuidString
        let clientID2 = UUID().uuidString
        let userSession1 = await setupSession(with: clientID1)
        let userSession2 = await setupSession(with: clientID2)

        let migration = APIMigrationMock(version: .v3)
        let sut = APIMigrationManager(migrations: [migration])

        sut.persistLastUsedAPIVersion(for: userSession1, apiVersion: .v2)
        sut.persistLastUsedAPIVersion(for: userSession2, apiVersion: .v2)

        // When
        await sut.migrateIfNeeded(sessions: [userSession1, userSession2], to: .v3)

        // Then
        guard migration.performCalls.count == 2 else {
            return XCTFail()
        }

        XCTAssertEqual(migration.performCalls[0].session, userSession1)
        XCTAssertEqual(migration.performCalls[0].clientID, clientID1)
        XCTAssertEqual(migration.performCalls[1].session, userSession2)
        XCTAssertEqual(migration.performCalls[1].clientID, clientID2)

        await tearDownSessions([userSession1, userSession2])
    }

    // MARK: - Persisting last used API version

    func test_itPersistsLastUsedAPIVersion_AfterMigrations() async {
        // Given
        let userSession = await stubUserSession()
        let clientID = "1234abcd"

        setupClient(clientID, in: userSession)

        let sut = APIMigrationManager(migrations: [])
        sut.persistLastUsedAPIVersion(for: userSession, apiVersion: .v0)

        // When
        await sut.migrateIfNeeded(sessions: [userSession], to: .v3)

        // Then
        XCTAssertEqual(sut.lastUsedAPIVersion(for: clientID), .v3)

        await tearDownSession(userSession)
    }

    func test_itPersistsLastUsedAPIVersion_ForMultipleSessions() async {
        // Given
        let sut = APIMigrationManager(migrations: [])

        let clientID1 = "client1"
        let clientID2 = "client2"
        let userSession1 = await setupSession(with: clientID1)
        let userSession2 = await setupSession(with: clientID2)

        sut.persistLastUsedAPIVersion(for: userSession1, apiVersion: .v1)
        sut.persistLastUsedAPIVersion(for: userSession2, apiVersion: .v1)

        XCTAssertEqual(sut.lastUsedAPIVersion(for: clientID1), APIVersion.v1)
        XCTAssertEqual(sut.lastUsedAPIVersion(for: clientID2), APIVersion.v1)

        // When
        sut.persistLastUsedAPIVersion(
            for: [userSession1, userSession2],
            apiVersion: .v3
        )

        // Then
        XCTAssertEqual(sut.lastUsedAPIVersion(for: clientID1), APIVersion.v3)
        XCTAssertEqual(sut.lastUsedAPIVersion(for: clientID2), APIVersion.v3)

        // clean up
        await tearDownSessions([userSession1, userSession2])
    }

    // MARK: - Helpers

    @MainActor
    private func setupSession(with clientID: String) -> ZMUserSession {
        let session = stubUserSession()
        setupClient(clientID, in: session)
        return session
    }

    @MainActor
    private func tearDownSessions(_ sessions: [ZMUserSession]) {
        sessions.forEach(tearDownSession(_:))
    }

    @MainActor
    private func tearDownSession(_ session: ZMUserSession) {
        if let clientID = session.selfUserClient?.remoteIdentifier {
            APIMigrationManager.removeDefaults(for: clientID)
        }
        session.tearDown()
    }

    private func setupClient(_ clientID: String, in userSession: ZMUserSession) {
        userSession.perform {
            let selfClient = UserClient.insertNewObject(in: userSession.managedObjectContext)
            selfClient.remoteIdentifier = clientID
            selfClient.user = ZMUser.selfUser(in: userSession.managedObjectContext)

            userSession.managedObjectContext.setPersistentStoreMetadata(
                clientID,
                key: ZMPersistedClientIdKey
            )

            XCTAssertNotNil(userSession.selfUserClient)
        }
    }

    @MainActor
    private func stubUserSession() -> ZMUserSession {
        let mockStrategyDirectory = MockStrategyDirectory()
        let mockCryptoboxMigrationManager = MockCryptoboxMigrationManagerInterface()

        let cookieStorage = ZMPersistentCookieStorage(
            forServerName: "test.example.com",
            userIdentifier: .create(),
            useCache: true
        )

        let mockTransportSession = RecordingMockTransportSession(
            cookieStorage: cookieStorage,
            pushChannel: MockPushChannel()
        )

        let mockContextStorable = MockLAContextStorable()
        mockContextStorable.clear_MockMethod = { }
        let configuration = ZMUserSession.Configuration()

        let mockRecurringActionService = MockRecurringActionServiceInterface()
        mockRecurringActionService.registerAction_MockMethod = { _ in }

        var builder = ZMUserSessionBuilder()
        builder.withAllDependencies(
            analytics: nil,
            appVersion: "999",
            application: application,
            cryptoboxMigrationManager: mockCryptoboxMigrationManager,
            coreDataStack: createCoreDataStack(),
            configuration: configuration,
            contextStorage: mockContextStorable,
            earService: nil,
            flowManager: FlowManagerMock(),
            mediaManager: MockMediaManager(),
            mlsService: nil,
            observeMLSGroupVerificationStatus: nil,
            proteusToMLSMigrationCoordinator: nil,
            recurringActionService: mockRecurringActionService,
            sharedUserDefaults: sharedUserDefaults,
            transportSession: mockTransportSession,
            useCaseFactory: nil,
            userId: .create()
        )

        let userSession = builder.build()
        userSession.setup(
            eventProcessor: MockUpdateEventProcessor(),
            strategyDirectory: mockStrategyDirectory,
            syncStrategy: nil,
            operationLoop: nil,
            configuration: configuration
        )

        return userSession
    }
}
