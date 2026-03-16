//
//  MessageCell+ReadMoreButton.swift
//  SceytChatUIKit
//
//  Copyright © 2024 Sceyt LLC. All rights reserved.
//

import UIKit

extension MessageCell {
    open class ReadMoreButton: Button {

        open var appearance: MessageCell.Appearance? {
            didSet {
                setupAppearance()
            }
        }

        open override func setup() {
            super.setup()
            contentHorizontalAlignment = .leading
            contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
            isUserInteractionEnabled = true
        }

        open override func setupAppearance() {
            super.setupAppearance()
            guard let appearance = appearance else { return }

            setTitle(appearance.readMoreText, for: .normal)
            setTitleColor(appearance.readMoreButtonAppearance.foregroundColor, for: .normal)
            titleLabel?.font = appearance.readMoreButtonAppearance.font
            backgroundColor = appearance.readMoreButtonAppearance.backgroundColor
        }
    }
}
