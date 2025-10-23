//
//  CreatePollViewController+OptionFieldCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension CreatePollViewController {
    open class OptionFieldCell: TableViewCell {

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

            containerView.pin(to: contentView, anchors: [.leading, .trailing, .top(0), .bottom(0)])
            containerView.heightAnchor.pin(greaterThanOrEqualToConstant: 44)

            textView.pin(to: containerView, anchors: [.leading(28), .trailing(-28), .top(12), .bottom(-12)])
            placeholderLabel.pin(to: containerView, anchors: [.leading(28), .trailing(-28), .top(12)])
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            containerView.backgroundColor = appearance.containerBackgroundColor
            containerView.layer.cornerRadius = appearance.cornerRadius
            containerView.layer.borderWidth = appearance.borderWidth
            containerView.layer.borderColor = appearance.borderColor.cgColor

            textView.textColor = appearance.textFieldAppearance.foregroundColor
            textView.font = appearance.textFieldAppearance.font
            textView.backgroundColor = .clear

            placeholderLabel.textColor = appearance.placeholderColor
            placeholderLabel.font = appearance.textFieldAppearance.font
        }

        open func updatePlaceholderVisibility() {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
}

extension CreatePollViewController.OptionFieldCell: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let validationPattern = appearance.validationPattern else {
            return true
        }

        // Calculate the resulting text after the change
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        // Allow empty text (user can delete everything)
        if updatedText.isEmpty {
            return true
        }

        // Validate against the pattern
        guard let regex = try? NSRegularExpression(pattern: validationPattern, options: []) else {
            return true
        }

        let matches = regex.matches(in: updatedText, options: [], range: NSRange(location: 0, length: updatedText.utf16.count))
        return !matches.isEmpty
    }

    public func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        onTextChanged?(textView.text)
        onHeightChanged?()
    }
}
