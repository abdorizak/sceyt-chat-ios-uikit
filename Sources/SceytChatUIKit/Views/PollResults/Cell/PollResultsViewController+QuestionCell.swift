//
//  PollResultsViewController+QuestionCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollResultsViewController {
    open class QuestionCell: TableViewCell {

        open lazy var questionLabel = UILabel()
            .withoutAutoresizingMask

        open lazy var containerView = UIView()
            .withoutAutoresizingMask

        open override func setup() {
            super.setup()
            questionLabel.numberOfLines = 0
        }

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(containerView)
            containerView.addSubview(questionLabel)

            containerView.pin(to: contentView, anchors: [.leading, .trailing, .top, .bottom])

            let space: CGFloat = 28.0
            questionLabel.pin(to: containerView, anchors: [.leading(space), .trailing(-space), .top(14), .bottom(-14)])
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            containerView.backgroundColor = appearance.containerBackgroundColor
            containerView.layer.cornerRadius = appearance.cornerRadius
            containerView.layer.borderWidth = appearance.borderWidth
            containerView.layer.borderColor = appearance.borderColor.cgColor

            questionLabel.textColor = appearance.questionLabelAppearance.foregroundColor
            questionLabel.font = appearance.questionLabelAppearance.font
        }

        open func configure(questionText: String) {
            questionLabel.text = questionText
        }
    }
}
