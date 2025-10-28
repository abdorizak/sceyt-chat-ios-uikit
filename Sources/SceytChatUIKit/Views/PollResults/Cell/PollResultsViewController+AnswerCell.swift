//
//  PollResultsViewController+AnswerCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollResultsViewController {
    open class AnswerCell: TableViewCell {

        open lazy var answerLabel = UILabel()
            .withoutAutoresizingMask

        open lazy var voteCountLabel = UILabel()
            .withoutAutoresizingMask

        open lazy var containerView = UIView()
            .withoutAutoresizingMask

        open override func setup() {
            super.setup()
            answerLabel.numberOfLines = 0
            voteCountLabel.numberOfLines = 1
            voteCountLabel.setContentHuggingPriority(.required, for: .horizontal)
            voteCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(containerView)
            containerView.addSubview(answerLabel)
            containerView.addSubview(voteCountLabel)

            containerView.pin(to: contentView, anchors: [.leading, .trailing, .top, .bottom])

            let space: CGFloat = 28.0
            let labelSpacing: CGFloat = 12.0

            // voteCountLabel on the right
            voteCountLabel.pin(to: containerView, anchors: [.trailing(-space)])
            voteCountLabel.topAnchor.pin(to: answerLabel.topAnchor)

            // answerLabel on the left, using remaining space
            answerLabel.pin(to: containerView, anchors: [.leading(space), .top(14), .bottom(-14)])
            answerLabel.trailingAnchor.pin(to: voteCountLabel.leadingAnchor, constant: -labelSpacing)
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            containerView.backgroundColor = appearance.containerBackgroundColor
            containerView.layer.cornerRadius = appearance.cornerRadius
            containerView.layer.borderWidth = appearance.borderWidth
            containerView.layer.borderColor = appearance.borderColor.cgColor

            answerLabel.textColor = appearance.answerLabelAppearance.foregroundColor
            answerLabel.font = appearance.answerLabelAppearance.font

            voteCountLabel.textColor = appearance.voteCountLabelAppearance.foregroundColor
            voteCountLabel.font = appearance.voteCountLabelAppearance.font
        }

        open func configure(answerText: String, voteCount: Int, totalVotes: Int) {
            answerLabel.text = answerText
            voteCountLabel.text = SceytChatUIKit.shared.formatters.voteCountFormatter.format(voteCount)
        }
    }
}
