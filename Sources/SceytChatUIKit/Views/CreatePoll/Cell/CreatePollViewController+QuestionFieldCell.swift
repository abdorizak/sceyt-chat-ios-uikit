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
        open var onReturnKeyPressed: (() -> Void)?

        open override func setup() {
            super.setup()

            textView.delegate = self
            textView.isScrollEnabled = false
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = .zero
            textView.returnKeyType = .next
        }

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(containerView)
            containerView.addSubview(textView)
            containerView.addSubview(placeholderLabel)

            containerView.pin(to: contentView, anchors: [.leading, .trailing, .top, .bottom])

            let space: CGFloat = 28.0
            textView.pin(to: containerView, anchors: [.leading(space), .trailing(-space), .top(14), .bottom(-14)])
            placeholderLabel.pin(to: containerView, anchors: [.leading(space), .trailing(-space), .top(14)])
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
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Handle return key press
        if text == "\n" {
            onReturnKeyPressed?()
            return false
        }

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

        // If validation fails, try to truncate the text to fit the max length from validation pattern
        if matches.isEmpty {
            // Extract max length from validation pattern (e.g., "^[\\s\\S]{1,120}$" -> 120)
            let pattern = validationPattern
            if let maxLengthMatch = try? NSRegularExpression(pattern: "\\{\\d+,(\\d+)\\}", options: [])
                .firstMatch(in: pattern, options: [], range: NSRange(location: 0, length: pattern.utf16.count)),
               let maxLengthRange = Range(maxLengthMatch.range(at: 1), in: pattern),
               let maxLength = Int(pattern[maxLengthRange]) {

                let remainingLength = maxLength - (currentText.count - range.length)

                if remainingLength > 0 && text.count > remainingLength {
                    // Truncate the replacement text to fit within the limit
                    let truncatedText = String(text.prefix(remainingLength))
                    let truncatedUpdatedText = currentText.replacingCharacters(in: stringRange, with: truncatedText)

                    // Update the text view manually
                    textView.text = truncatedUpdatedText

                    // Set cursor position after the inserted text
                    if let newPosition = textView.position(from: textView.beginningOfDocument, offset: range.location + truncatedText.count) {
                        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                    }

                    // Trigger the text changed callback
                    textViewDidChange(textView)

                    return false
                }
            }
        }

        return !matches.isEmpty
    }

    public func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        onTextChanged?(textView.text)
        onHeightChanged?()
    }
}
