//
//  PollTypeFormatter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation

open class PollTypeFormatter: PollTypeFormatting {

    public init() {}

    open func format(_ poll: (closed: Bool, anonymous: Bool)) -> String {
        if poll.closed {
            return "Poll finished"
        } else {
            if poll.anonymous {
                return "Anonymous poll"
            } else {
                return "Public poll"
            }
        }
    }
}
