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
            row: [titleLabel, subTitleLabel],
            spacing: 8,
            alignment: .fill
        )
            .withoutAutoresizingMask

        open lazy var titleLabel = UILabel()
            .withoutAutoresizingMask
            .contentCompressionResistancePriorityH(.defaultLow)

        open lazy var subTitleLabel = UILabel()
            .withoutAutoresizingMask
            .contentCompressionResistancePriorityH(.required)

        open lazy var separatorView = UIView()
            .withoutAutoresizingMask
        
        var imageTask: Cancellable?

        override open func setup() {
            super.setup()
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.numberOfLines = 1
            subTitleLabel.numberOfLines = 1
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

            subTitleLabel.textColor = appearance.subtitleLabelAppearance.foregroundColor
            subTitleLabel.font = appearance.subtitleLabelAppearance.font
            subTitleLabel.textAlignment = .right
        }

        override open func setupLayout() {
            super.setupLayout()
            contentView.addSubview(avatarView)
            contentView.addSubview(textStackView)
            contentView.addSubview(separatorView)

            let avatarSize = appearance.avatarSize
            avatarView.leadingAnchor.pin(to: contentView.leadingAnchor, constant: 0)
            avatarView.pin(to: contentView, anchors: [.top(8, .greaterThanOrEqual), .centerY()])
            avatarView.resize(anchors: [.height(avatarSize.height), .width(avatarSize.width)])
            avatarView.layer.cornerRadius = avatarSize.height / 2
            avatarView.clipsToBounds = true

            textStackView.leadingAnchor.pin(to: avatarView.trailingAnchor, constant: 12)
            textStackView.centerYAnchor.pin(to: avatarView.centerYAnchor)
            textStackView.trailingAnchor.pin(to: contentView.trailingAnchor, constant: 0)

            separatorView.pin(to: contentView, anchors: [.bottom, .trailing(-16)])
            separatorView.leadingAnchor.pin(to: titleLabel.leadingAnchor)
            separatorView.heightAnchor.pin(constant: 1)
            contentView.heightAnchor.pin(greaterThanOrEqualToConstant: 56)
        }

        open var data: PollOptionResult.Voter! {
            didSet {
                guard let data else { return }

                titleLabel.text = data.member.displayName
                subTitleLabel.text = SceytChatUIKit.shared.formatters.voterDateFormatter.format(data.votedAt)

                imageTask?.cancel()
                imageTask = appearance.avatarRenderer.render(
                    data.member,
                    with: appearance.avatarAppearance,
                    into: avatarView
                )
            }
        }

        override open func prepareForReuse() {
            super.prepareForReuse()
            avatarView.image = nil
            imageTask?.cancel()
        }
    }
}
