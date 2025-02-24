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

import UIKit
import WireCommonComponents

extension ValidatedTextField {
    static func createPasscodeTextField(kind: ValidatedTextField.Kind,
                                        delegate: ValidatedTextFieldDelegate & TextFieldValidationDelegate,
                                        setNewColors: Bool) -> ValidatedTextField {
        let textField = ValidatedTextField(kind: kind,
                                           leftInset: 0,
                                           accessoryTrailingInset: 0,
                                           cornerRadius: 16,
                                           setNewColors: setNewColors, style: .default)

        textField.overrideButtonIcon = StyleKitIcon.AppLock.reveal
        textField.validatedTextFieldDelegate = delegate
        textField.textFieldValidationDelegate = delegate

        textField.heightAnchor.constraint(equalToConstant: CGFloat.PasscodeUnlock.textFieldHeight).isActive = true

        return textField

    }

    func updatePasscodeIcon() {
        overrideButtonIcon = isSecureTextEntry ? StyleKitIcon.AppLock.reveal : StyleKitIcon.AppLock.hide
    }
}
