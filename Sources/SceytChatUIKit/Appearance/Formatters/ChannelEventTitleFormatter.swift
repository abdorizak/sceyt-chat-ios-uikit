//
//  ChannelEventTitleFormatter.swift
//  SceytChatUIKit
//
//  Created by Sergey Charchoghlyan on 02.07.25.
//

import Foundation

open class ChannelEventTitleFormatter: ChannelEventTitleFormatting {
    
    public init() {}
    
    open func format(_ attributes: ChannelEventTitleFormatterAttributes) -> NSAttributedString {
        if attributes.channel.isDirect {
            let title = attributes.models.first?.event.title
            return NSAttributedString(string: title ?? "")
        } else {
            let displayName: String
            if let user = attributes.models.first?.user {
                displayName = SceytChatUIKit.shared.formatters.userNameFormatter.format(user)
            } else {
                displayName = attributes.models.first?.user.displayName ?? ""
            }
            let title = attributes.models.first?.event.title ?? ""
            let text = "\(displayName) \(title)"
            return NSAttributedString(string: text)
        }
    }
}
