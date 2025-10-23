//
//  CreatePollViewController+QuestionFieldCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension CreatePollViewController {
    open class QuestionFieldCell: TableViewCell {

        open lazy var textView = UITextView()
            .withoutAutoresizingMask

        open lazy var placeholderLabel = UILabel()
            .withoutAutoresizingMask

        open lazy var containerView = UIView()
            .withoutAutoresizingMask

        open var onTextChanged: ((String) -> Void)?
        open var onHeightChanged: (() -> Void)?

        open override func setup() {
            super.setup()

            textView.delegate = self
            textView.isScrollEnabled = false
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = .zero
        }

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(containerView)
            containerView.addSubview(textView)
            containerView.addSubview(placeholderLabel)

            containerView.pin(to: contentView, anchors: [.leading, .trailing, .top, .bottom])
            containerView.heightAnchor.pin(greaterThanOrEqualToConstant: 48.0)

            let space: CGFloat = 28.0
            textView.pin(to: containerView, anchors: [.leading(space), .trailing(-space), .top(12), .bottom(-12)])
            placeholderLabel.pin(to: containerView, anchors: [.leading(space), .trailing(-space), .top(12)])
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            containerView.backgroundColor = appearance.containerBackgroundColor
            containerView.layer.cornerRadius = appearance.cornerRadius
            containerView.layer.borderWidth = appearance.borderWidth
            containerView.layer.borderColor = appearance.borderColor.cgColor

            textView.textColor = appearance.textViewAppearance.foregroundColor
            textView.font = appearance.textViewAppearance.font
            textView.backgroundColor = .clear

            placeholderLabel.textColor = appearance.placeholderColor
            placeholderLabel.font = appearance.textViewAppearance.font
        }

        open func updatePlaceholderVisibility() {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
}

extension CreatePollViewController.QuestionFieldCell: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        onTextChanged?(textView.text)
        onHeightChanged?()
    }
}
