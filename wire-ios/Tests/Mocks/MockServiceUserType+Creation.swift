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
import WireTesting

extension MockServiceUserType {

    /// Creates a service user with the specified name.
    ///
    /// - Parameters:
    ///   - name: The name of the user.
    ///
    /// - Returns: A standard mock service user object with default values.

    class func createServiceUser(name: String) -> MockServiceUserType {
        let serviceUser = MockServiceUserType()
        serviceUser.name = name
        serviceUser.displayName = name
        serviceUser.initials = PersonName.person(withName: name, schemeTagger: nil).initials
        serviceUser.handle = serviceUser.name?.lowercased()
        serviceUser.zmAccentColor = .amber
        serviceUser.providerIdentifier = UUID.create().transportString()
        serviceUser.serviceIdentifier = UUID.create().transportString()
        return serviceUser
    }
}
