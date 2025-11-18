//
//  UnsupportedMessageFormatter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

open class UnsupportedMessageFormatter: UnsupportedMessageFormatting {

    public init() {}

    open func format(_ attributes: ChatMessage) -> NSAttributedString {
        let messageText = L10n.Message.Unsupported.text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.regularItalic.withSize(16.0),
            .foregroundColor: DefaultColors.unsupprotedMessageText
        ]

        let attributedString = NSAttributedString(string: messageText, attributes: attributes)
        return attributedString
    }
}

