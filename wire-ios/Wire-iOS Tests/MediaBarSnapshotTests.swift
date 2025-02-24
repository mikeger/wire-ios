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

final class MediaBarSnapshotTests: ZMSnapshotTestCase {

    var sut: MediaBar!

    override func setUp() {
        super.setUp()
        sut = MediaBar()
        sut.titleLabel.text = "demo media"

        sut.backgroundColor = .black
        sut.frame = CGRect(x: 0, y: 0, width: 375, height: sut.intrinsicContentSize.height)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testForInitState() {
        verify(view: sut)
    }
}
