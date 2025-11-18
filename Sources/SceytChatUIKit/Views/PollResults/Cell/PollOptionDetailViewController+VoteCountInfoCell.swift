//
//  PollOptionDetailViewController+VoteCountInfoCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollOptionDetailViewController {
    open class VoteCountInfoCell: TableViewCell {

        open lazy var infoLabel = UILabel()
            .withoutAutoresizingMask

        open lazy var containerView = UIView()
            .withoutAutoresizingMask

        open override func setup() {
            super.setup()
            infoLabel.numberOfLines = 1
            infoLabel.textAlignment = .left
        }

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(containerView)
            containerView.addSubview(infoLabel)

            containerView.pin(to: contentView, anchors: [.leading, .trailing, .top, .bottom])

            let space: CGFloat = 28.0
            infoLabel.pin(to: containerView, anchors: [.leading(space), .trailing(-space), .top(12), .bottom(-12)])
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            containerView.backgroundColor = appearance.containerBackgroundColor
            containerView.layer.cornerRadius = appearance.cornerRadius
            containerView.layer.borderWidth = appearance.borderWidth
            containerView.layer.borderColor = appearance.borderColor.cgColor

            infoLabel.textColor = appearance.infoLabelAppearance.foregroundColor
            infoLabel.font = appearance.infoLabelAppearance.font
        }

        open func configure(text: String) {
            infoLabel.text = text
        }
    }
}
