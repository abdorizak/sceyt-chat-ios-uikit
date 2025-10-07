//
//  ChannelInviteLinkViewModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat

open class ChannelInviteLinkViewModel: NSObject {

    public let channel: ChatChannel

    public var inviteLink: String? {
        // TODO: Implement actual invite link generation
        return "https://sceyt.app/invite/\(channel.id)"
    }

    public var showPreviousMessages: Bool = false {
        didSet {
            // TODO: Update backend setting
        }
    }

    public required init(channel: ChatChannel) {
        self.channel = channel
        super.init()
    }
}
