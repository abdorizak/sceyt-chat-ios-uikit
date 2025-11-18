//
//  UnsupportedMessageShortFormatter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

open class UnsupportedMessageShortFormatter: UnsupportedMessageShortFormatting {

    public init() {}

    open func format(_ message: ChatMessage) -> NSAttributedString {
        let messageText = L10n.Message.Unsupported.text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.regularItalic.withSize(15.0),
            .foregroundColor: DefaultColors.unsupprotedMessageText
        ]

        let attributedString = NSAttributedString(string: messageText, attributes: attributes)
        return attributedString
    }
}

