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

import SafariServices
import UIKit

extension UIAlertController {
    static func requestTOSApproval(over controller: UIViewController, forTeamAccount: Bool, completion: @escaping (_ approved: Bool) -> Void) {
        let alert = UIAlertController(title: L10n.Localizable.Registration.TermsOfUse.Terms.title,
                                      message: L10n.Localizable.Registration.TermsOfUse.Terms.message,
                                      preferredStyle: .alert)
        let viewAction = UIAlertAction(title: L10n.Localizable.Registration.TermsOfUse.Terms.view, style: .default) { [weak controller] _ in
            let url = URL.wr_termsOfServicesURL.appendingLocaleParameter

            let webViewController: BrowserViewController
            webViewController = BrowserViewController(url: url)
            webViewController.completion = { [weak controller] in
                if let controller = controller {
                    UIAlertController.requestTOSApproval(over: controller, forTeamAccount: forTeamAccount, completion: completion)
                }
            }
            controller?.present(webViewController, animated: true)
        }
        alert.addAction(viewAction)

        let cancelAction = UIAlertAction(title: L10n.Localizable.General.cancel, style: .cancel) { _ in
            completion(false)
        }
        alert.addAction(cancelAction)

        let acceptAction = UIAlertAction(title: L10n.Localizable.Registration.TermsOfUse.accept, style: .default) { _ in
            completion(true)
        }
        alert.addAction(acceptAction)
        alert.preferredAction = acceptAction

        controller.present(alert, animated: true, completion: nil)
    }
}
