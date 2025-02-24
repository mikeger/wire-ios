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

final class ConversationParticipantsSystemMessageCell: ConversationIconBasedCell, ConversationMessageCell {

    private typealias LabelColors = SemanticColors.Label

    struct Configuration: Equatable {
        let icon: UIImage?
        let attributedText: NSAttributedString?
        let showLine: Bool
        let warning: String?
    }

    private let warningLabel = UILabel()

    override func configureSubviews() {
        super.configureSubviews()
        warningLabel.numberOfLines = 0
        warningLabel.isAccessibilityElement = true
        warningLabel.font = FontSpec(.small, .regular).font
        warningLabel.textColor = LabelColors.textErrorDefault
        bottomContentView.addSubview(warningLabel)
    }

    override func configureConstraints() {
        super.configureConstraints()
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.fitIn(view: bottomContentView)
    }

    // MARK: - Configuration

    func configure(with object: Configuration, animated: Bool) {
        lineView.isHidden = !object.showLine
        imageView.image = object.icon
        attributedText = object.attributedText
        warningLabel.text = object.warning
    }
}
