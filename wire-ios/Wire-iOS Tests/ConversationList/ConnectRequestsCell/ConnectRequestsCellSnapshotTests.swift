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

final class ConnectRequestsCellSnapshotTests: XCTestCase {

    var sut: ConnectRequestsCell!

    override func setUp() {
        super.setUp()
        accentColor = .amber
        sut = ConnectRequestsCell(frame: CGRect(x: 0, y: 0, width: 375, height: 56))
        let titleString = L10n.Localizable.List.ConnectRequest.peopleWaiting(1)
        let title = NSAttributedString(string: titleString)
        let otherUser = MockUserType.createDefaultOtherUser()
        sut.itemView.configure(with: title, subtitle: nil, users: [otherUser])
        sut.backgroundColor = .black
        sut.overrideUserInterfaceStyle = .dark
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testForInitState() {
        verify(matching: sut)
    }
}
