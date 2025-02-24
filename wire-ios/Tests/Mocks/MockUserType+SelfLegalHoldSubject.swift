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
import WireCryptobox

extension MockUserType: SelfLegalHoldSubject {

    var legalHoldStatus: UserLegalHoldStatus {
        if isUnderLegalHold {
            return .enabled
        } else if let request = legalHoldDataSource.legalHoldRequest {
            return .pending(request)
        } else {
            return .disabled
        }
    }

    var needsToAcknowledgeLegalHoldStatus: Bool {
        return legalHoldDataSource.needsToAcknowledgeLegalHoldStatus
    }

    var fingerprint: String? {
        guard let preKey = legalHoldDataSource.legalHoldRequest?.lastPrekey,
              let fingerprintData = EncryptionSessionsDirectory.fingerprint(fromPrekey: preKey.key) else {
                  return nil
              }
        return String(data: fingerprintData, encoding: .utf8)
    }

    func legalHoldRequestWasCancelled() {
        legalHoldDataSource.legalHoldRequest = nil
    }

    func userDidReceiveLegalHoldRequest(_ request: LegalHoldRequest) {
        legalHoldDataSource.legalHoldRequest = request
    }

    func userDidAcceptLegalHoldRequest(_ request: LegalHoldRequest) {
        legalHoldDataSource.legalHoldRequest = nil
        isUnderLegalHold = true
    }

    func acknowledgeLegalHoldStatus() {
        legalHoldDataSource.needsToAcknowledgeLegalHoldStatus = false
    }

    func requestLegalHold() {
        let keyData = Data(base64Encoded: "pQABARn//wKhAFggHsa0CszLXYLFcOzg8AA//E1+Dl1rDHQ5iuk44X0/PNYDoQChAFgg309rkhG6SglemG6kWae81P1HtQPx9lyb6wExTovhU4cE9g==")!
        let prekey = LegalHoldRequest.Prekey(id: 65535, key: keyData)

        legalHoldDataSource.legalHoldRequest = LegalHoldRequest(target: UUID(),
                                                                requester: UUID(),
                                                                clientIdentifier: "eca3c87cfe28be49",
                                                                lastPrekey: prekey)
    }

}
