//
//  ChannelInviteLinkViewController+ActionCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension ChannelInviteLinkViewController {
    open class ActionCell: TableViewCell {

        open lazy var iconView = UIImageView()
            .withoutAutoresizingMask

        open lazy var titleLabel = UILabel()
            .withoutAutoresizingMask



        open override func setup() {
            super.setup()

            iconView.contentMode = .scaleAspectFit
        }

        private var titleLeadingConstraint: NSLayoutConstraint?
        private var titleLeadingToIconConstraint: NSLayoutConstraint?

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(iconView)
            contentView.addSubview(titleLabel)

            iconView.pin(to: contentView, anchors: [.leading, .centerY])
            iconView.resize(anchors: [.height(24), .width(24)])

            titleLabel.pin(to: contentView, anchors: [.top(12), .bottom(-12)])
            titleLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            titleLeadingToIconConstraint = titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12)
            titleLeadingToIconConstraint?.isActive = true
            titleLabel.trailingAnchor.pin(to: contentView.trailingAnchor, constant: -16)

            contentView.heightAnchor.pin(greaterThanOrEqualToConstant: 56)
        }

        open override func prepareForReuse() {
            super.prepareForReuse()
            iconView.isHidden = false
            titleLeadingToIconConstraint?.isActive = true
            titleLeadingConstraint?.isActive = false
        }

        open override func layoutSubviews() {
            super.layoutSubviews()
            if iconView.isHidden {
                titleLeadingToIconConstraint?.isActive = false
                titleLeadingConstraint?.isActive = true
            } else {
                titleLeadingConstraint?.isActive = false
                titleLeadingToIconConstraint?.isActive = true
            }
        }

        open override var safeAreaInsets: UIEdgeInsets {
            .init(top: 0, left: 2 * ChannelInviteLinkViewController.Layouts.cellHorizontalPadding,
                  bottom: 0, right: 2 * ChannelInviteLinkViewController.Layouts.cellHorizontalPadding)
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            titleLabel.textColor = appearance.titleLabelAppearance.foregroundColor
            titleLabel.font = appearance.titleLabelAppearance.font
        }
    }
}
