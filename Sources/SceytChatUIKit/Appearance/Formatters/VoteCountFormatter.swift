//
//  VoteCountFormatter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation

open class VoteCountFormatter: VoteCountFormatting {

    public init() {}

    open func format(_ count: Int) -> String {
        count == 1 ? "1 vote" : "\(count) votes"
    }
}
