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

    open func format(_ poll: (closed: Bool, anonymous: Bool, isSingle: Bool)) -> String {
        if poll.closed {
            return L10n.Poll.Types.finished
        } else {
            var strings: [String] = []
            if poll.anonymous {
                strings.append(L10n.Poll.Types.anonymous)
            }

            if poll.isSingle {
                strings.append(L10n.Poll.Types.singleVote)
            } else {
                strings.append(L10n.Poll.Types.multipleVotes)
            }

            return strings.joined(separator: " • ")
        }
    }
}
