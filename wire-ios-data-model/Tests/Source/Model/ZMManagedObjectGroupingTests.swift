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
@testable import WireDataModel
import XCTest

class ZMManagedObjectGroupingTests: DatabaseBaseTest {

    var mocs: CoreDataStack!

    public override func setUp() {
        super.setUp()
        self.mocs = self.createStorageStackAndWaitForCompletion()
        XCTAssert(waitForAllGroupsToBeEmpty(withTimeout: 1))
    }

    public override func tearDown() {
        self.mocs = nil
        super.tearDown()
    }

    public func testThatItFindsNoDuplicates_None() {
        // WHEN
        let duplicates: [UUID: [ZMUser]] = self.mocs.viewContext.findDuplicated(by: #keyPath(ZMUser.name))

        // THEN
        XCTAssertEqual(duplicates.keys.count, 0)
    }

    public func testThatItFindsNoDuplicates_One() {
        // GIVEN
        let user = ZMUser.insertNewObject(in: self.mocs.viewContext)
        user.name = "foo"

        self.mocs.viewContext.saveOrRollback()

        // WHEN
        let duplicates: [String: [ZMUser]] = self.mocs.viewContext.findDuplicated(by: #keyPath(ZMUser.name))

        // THEN
        XCTAssertEqual(duplicates.keys.count, 0)
    }

    public func testThatItFindsDuplicates_ManyCommon() {
        // GIVEN
        let name = "foo"

        for _ in 1...10 {
            let user = ZMUser.insertNewObject(in: self.mocs.viewContext)
            user.name = name
        }

        self.mocs.viewContext.saveOrRollback()

        // WHEN
        let duplicates: [String: [ZMUser]] = self.mocs.viewContext.findDuplicated(by: #keyPath(ZMUser.name))

        // THEN
        XCTAssertEqual(duplicates.keys.count, 1)
        XCTAssertEqual(duplicates[name]?.count, 10)
    }

    public func testThatItGroupsByPropertyValue_One() {
        // GIVEN
        let client = UserClient.insertNewObject(in: self.mocs.viewContext)
        client.remoteIdentifier = UUID().transportString()
        client.user = ZMUser.insert(in: self.mocs.viewContext, name: "User")

        // WHEN
        let grouped: [ZMUser: [UserClient]] = [client].group(by: ZMUserClientUserKey)

        // THEN
        XCTAssertEqual(grouped.keys.count, 1)
        for key in grouped.keys {
            XCTAssertEqual(grouped[key]!.count, 1)
        }
    }

    public func testThatItGroupsByPropertyValue_Many() {
        // GIVEN
        let range = 1...10
        let user = ZMUser.insert(in: self.mocs.viewContext, name: "User")
        let clients: [UserClient] = range.map { _ in
            let client = UserClient.insertNewObject(in: self.mocs.viewContext)
            client.remoteIdentifier = UUID().transportString()
            client.user = user
            return client
        }

        // WHEN
        let grouped: [ZMUser: [UserClient]] = clients.group(by: ZMUserClientUserKey)

        // THEN
        XCTAssertEqual(grouped.keys.count, 1)
        XCTAssertEqual(grouped.keys.first, user)
        for key in grouped.keys {
            XCTAssertEqual(grouped[key]!.count, 10)
        }
    }

    public func testThatItGroupsByPropertyValue_ManyDistinct() {
        // GIVEN
        let range = 1...10
        let clients: [UserClient] = range.map {
            let client = UserClient.insertNewObject(in: self.mocs.viewContext)
            client.remoteIdentifier = UUID().transportString()
            client.user = ZMUser.insert(in: self.mocs.viewContext, name: "User \($0)")
            return client
        }

        // WHEN
        let grouped: [ZMUser: [UserClient]] = clients.group(by: ZMUserClientUserKey)

        // THEN
        XCTAssertEqual(grouped.keys.count, 10)
        for key in grouped.keys {
            XCTAssertEqual(grouped[key]!.count, 1)
        }
    }

    public func testThatItIgnoresNil() {
        // GIVEN
        let range = 1...10
        let clients: [UserClient] = range.map { _ in
            let client = UserClient.insertNewObject(in: self.mocs.viewContext)
            client.remoteIdentifier = UUID().transportString()
            client.user = nil
            return client
        }

        // WHEN
        let grouped: [ZMUser: [UserClient]] = clients.group(by: ZMUserClientUserKey)

        // THEN
        XCTAssertEqual(grouped.keys.count, 0)
    }
}
