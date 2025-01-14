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
import XCTest

@testable import WireUtilities

class ArrayShiftTests: XCTestCase {
    func testRightShift() {
        // GIVEN
        let sut = [0, 1, 2, 3, 4]
        let expected = [4, 0, 1, 2, 3]

        // WHEN / THEN
        XCTAssertEqual(sut.shifted(by: 1), expected)
    }

    func testLeftShift() {
        // GIVEN
        let sut = [0, 1, 2, 3, 4]
        let expected = [1, 2, 3, 4, 0]

        // WHEN / THEN
        XCTAssertEqual(sut.shifted(by: -1), expected)
    }

    func testShiftByAmountBiggerThanArraySize() {
        // GIVEN
        let sut = [0, 1, 2, 3, 4]
        let expected = [4, 0, 1, 2, 3]

        // WHEN / THEN
        XCTAssertEqual(sut.shifted(by: 6), expected)
    }
}
