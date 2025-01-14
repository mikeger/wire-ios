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

@testable import Wire
import XCTest

final class GroupDetailsTimeoutOptionsCellTests: CoreDataSnapshotTestCase {

    var cell: GroupDetailsTimeoutOptionsCell!
    var conversation: ZMConversation!

    override func setUp() {
        super.setUp()
        cell = GroupDetailsTimeoutOptionsCell(frame: CGRect(x: 0, y: 0, width: 350, height: 56))
        conversation = createGroupConversation()
    }

    override func tearDown() {
        cell = nil
        conversation = nil
        super.tearDown()
    }

    func testThatItDisplaysCell_WithoutTimeout_Light() {
        updateTimeout(0)
        cell.overrideUserInterfaceStyle = .light
        verify(matching: cell)
    }

    func testThatItDisplaysCell_WithoutTimeout_Dark() {
        updateTimeout(0)
        cell.overrideUserInterfaceStyle = .dark
        verify(matching: cell)
    }

    func testThatItDisplaysCell_WithTimeout_Light() {
        updateTimeout(300)
        cell.overrideUserInterfaceStyle = .light
        verify(matching: cell)
    }

    func testThatItDisplaysCell_WithTimeout_Dark() {
        updateTimeout(300)
        cell.overrideUserInterfaceStyle = .dark
        verify(matching: cell)
    }

    private func updateTimeout(_ newValue: TimeInterval) {
        conversation.setMessageDestructionTimeoutValue(.init(rawValue: newValue), for: .groupConversation)
        cell.configure(with: (conversation as Any) as! ZMConversation)
    }

}
