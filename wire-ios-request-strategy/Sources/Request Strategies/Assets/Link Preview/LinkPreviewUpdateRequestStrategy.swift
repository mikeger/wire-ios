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

public class LinkPreviewUpdateRequestStrategy: NSObject, ZMContextChangeTrackerSource {

    let managedObjectContext: NSManagedObjectContext
    let modifiedKeysSync: ModifiedKeyObjectSync<LinkPreviewUpdateRequestStrategy>
    let messageSender: MessageSenderInterface

    static func linkPreviewIsUploadedPredicate(context: NSManagedObjectContext) -> NSPredicate {
        return NSPredicate(format: "%K == %@ AND %K == %d",
                           #keyPath(ZMClientMessage.sender), ZMUser.selfUser(in: context),
                           #keyPath(ZMClientMessage.linkPreviewState), ZMLinkPreviewState.uploaded.rawValue)
    }

    public init(managedObjectContext: NSManagedObjectContext,
                messageSender: MessageSenderInterface) {

        let modifiedPredicate = Self.linkPreviewIsUploadedPredicate(context: managedObjectContext)
        self.modifiedKeysSync = ModifiedKeyObjectSync(trackedKey: ZMClientMessage.linkPreviewStateKey,
                                                      modifiedPredicate: modifiedPredicate)

        self.managedObjectContext = managedObjectContext
        self.messageSender = messageSender

        super.init()

        self.modifiedKeysSync.transcoder = self
    }

    public var contextChangeTrackers: [ZMContextChangeTracker] {
        return [modifiedKeysSync]
    }
}

extension LinkPreviewUpdateRequestStrategy: ModifiedKeyObjectSyncTranscoder {

    typealias Object = ZMClientMessage

    func synchronize(key: String, for object: ZMClientMessage, completion: @escaping () -> Void) {
        // Enter groups to enable waiting for message sending to complete in tests
        let groups = managedObjectContext.enterAllGroupsExceptSecondary()
        Task {
            do {
                try await messageSender.sendMessage(message: object)
            } catch {
                WireLogger.calling.error("failed to send message: \(String(reflecting: error))")
            }
            await managedObjectContext.perform {
                object.linkPreviewState = .done
                completion()
            }
            managedObjectContext.leaveAllGroups(groups)
        }
    }

}
