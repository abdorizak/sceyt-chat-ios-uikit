//
//  PollResultsViewController+VoterCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollResultsViewController {
    open class VoterCell: TableViewCell {

        open lazy var avatarView = ImageView
            .init()
            .contentMode(.scaleAspectFill)
            .withoutAutoresizingMask

        private lazy var textStackView = UIStackView(
            column: [titleLabel, statusLabel],
            spacing: 3,
            alignment: .leading
        )
            .withoutAutoresizingMask

        open lazy var titleLabel = UILabel()
            .withoutAutoresizingMask
            .contentCompressionResistancePriorityH(.defaultLow)

        open lazy var statusLabel = UILabel()
            .withoutAutoresizingMask
            .contentCompressionResistancePriorityH(.defaultLow)

        open lazy var separatorView = UIView()
            .withoutAutoresizingMask

        override open func setup() {
            super.setup()
        }

        open override var safeAreaInsets: UIEdgeInsets {
            .init(top: 0, left: 2 * PollResultsViewController.Layouts.cellHorizontalPadding,
                  bottom: 0, right: 2 * PollResultsViewController.Layouts.cellHorizontalPadding)
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            contentView.backgroundColor = .clear
            separatorView.isHidden = true

            titleLabel.textColor = appearance.titleLabelAppearance.foregroundColor
            titleLabel.font = appearance.titleLabelAppearance.font

            statusLabel.textColor = appearance.subtitleLabelAppearance.foregroundColor
            statusLabel.font = appearance.subtitleLabelAppearance.font
        }

        override open func setupLayout() {
            super.setupLayout()
            contentView.addSubview(avatarView)
            contentView.addSubview(textStackView)
            contentView.addSubview(separatorView)

            let avatarSize = appearance.avatarSize
            avatarView.leadingAnchor.pin(to: contentView.leadingAnchor, constant: 16)
            avatarView.pin(to: contentView, anchors: [.top(8, .greaterThanOrEqual), .centerY()])
            avatarView.resize(anchors: [.height(avatarSize.height), .width(avatarSize.width)])
            avatarView.layer.cornerRadius = avatarSize.height / 2
            avatarView.clipsToBounds = true

            textStackView.leadingAnchor.pin(to: avatarView.trailingAnchor, constant: 12)
            textStackView.pin(to: contentView, anchors: [.top(8, .greaterThanOrEqual), .centerY])
            textStackView.trailingAnchor.pin(to: contentView.trailingAnchor, constant: -16)

            separatorView.topAnchor.pin(greaterThanOrEqualTo: textStackView.bottomAnchor, constant: 8)
            separatorView.pin(to: contentView, anchors: [.bottom, .trailing(-16)])
            separatorView.leadingAnchor.pin(to: titleLabel.leadingAnchor)
            separatorView.heightAnchor.pin(constant: 1)
            contentView.heightAnchor.pin(greaterThanOrEqualToConstant: 56)
        }

        var imageTask: Cancellable?

        open var data: ChatChannelMember! {
            didSet {
                guard let data else { return }

                titleLabel.text = data.displayName
                statusLabel.text = ""

//                imageTask = appearance.avatarRenderer.render(
//                    data,
//                    with: appearance.avatarAppearance,
//                    into: avatarView
//                )
            }
        }

        override open func prepareForReuse() {
            super.prepareForReuse()
            avatarView.image = nil
            imageTask?.cancel()
        }
    }
}
