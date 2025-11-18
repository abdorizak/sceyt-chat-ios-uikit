//
//  MessageCell+UnsupportedMessageView.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension MessageCell {
    open class UnsupportedMessageView: View, MessageCellMeasurable {
        open lazy var messageLabel: UITextView = {
            let textView = UITextView()
                .withoutAutoresizingMask
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.backgroundColor = .clear
            textView.isUserInteractionEnabled = true
            return textView
        }()

        open var data: MessageLayoutModel? {
            didSet {
                guard let data = data else {
                    isHidden = true
                    return
                }

                guard data.contentOptions.contains(.unsupported) else {
                    isHidden = true
                    return
                }

                messageLabel.attributedText = Components.messageCell.appearance.unsupportedMessageFormatter.format(data.message)
                isHidden = false
            }
        }

        override open func setup() {
            super.setup()

            layer.cornerRadius = 16
        }

        override open func setupLayout() {
            super.setupLayout()

            addSubview(messageLabel)
            messageLabel.pin(to: self, anchors: [.leading(8.0), .trailing(-8.0), .top, .bottom])
        }

        override open func setupAppearance() {
            super.setupAppearance()

            backgroundColor = .clear
        }

        open class func measure(
            model: MessageLayoutModel,
            appearance: MessageCell.Appearance
        ) -> CGSize {
            guard model.contentOptions.contains(.unsupported) else {
                return .zero
            }

            let contentMaxWidth = Components.messageLayoutModel.defaults.messageWidth - 16.0
            let attributedString = SceytChatUIKit.shared.formatters.unsupportedMessageFormatter.format(model.message)

            let config = TextSizeMeasure.Config(
                restrictingWidth: contentMaxWidth,
                maximumNumberOfLines: 0,
                font: .systemFont(ofSize: 16.0),
                lastFragmentUsedRect: false
            )

            let textSize = TextSizeMeasure.calculateSize(of: attributedString, config: config).textSize
            let height = 8.0 + ceil(textSize.height) // top + bottom padding

            return CGSize(width: textSize.width + 16.0, height: ceil(height))
        }
    }
}
