//
//  PollResultsViewController+ShowMoreCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollResultsViewController {
    open class ShowMoreCell: TableViewCell {

        open lazy var showMoreButton = UIButton()
            .withoutAutoresizingMask

        open lazy var containerView = UIView()
            .withoutAutoresizingMask

        open override func setup() {
            super.setup()
        }

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(containerView)
            containerView.addSubview(showMoreButton)

            containerView.pin(to: contentView, anchors: [.leading, .trailing, .top, .bottom])
            containerView.heightAnchor.pin(greaterThanOrEqualToConstant: 44)

            let space: CGFloat = 28.0
            showMoreButton.pin(to: containerView, anchors: [.leading(space), .trailing(-space), .top(12), .bottom(-12)])
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            containerView.backgroundColor = appearance.containerBackgroundColor
            containerView.layer.cornerRadius = appearance.cornerRadius
            containerView.layer.borderWidth = appearance.borderWidth
            containerView.layer.borderColor = appearance.borderColor.cgColor

            let buttonAppearance = appearance.showMoreButtonAppearance
            showMoreButton.setTitleColor(buttonAppearance.labelAppearance.foregroundColor, for: .normal)
            showMoreButton.backgroundColor = buttonAppearance.backgroundColor
            showMoreButton.layer.cornerRadius = buttonAppearance.cornerRadius
            showMoreButton.layer.cornerCurve = buttonAppearance.cornerCurve
            showMoreButton.titleLabel?.font = buttonAppearance.labelAppearance.font
            showMoreButton.tintColor = buttonAppearance.tintColor
        }

        open func configure(text: String) {
            showMoreButton.setTitle(text, for: .normal)
        }
    }
}
