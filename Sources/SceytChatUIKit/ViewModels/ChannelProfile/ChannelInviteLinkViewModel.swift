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
        guard let config = SceytChatUIKit.shared.config.channelInviteDeepLinkConfig else {
            return nil
        }
        return config.constructInviteLink(for: channel.uri)
    }

    public var showPreviousMessages: Bool = false {
        didSet {
            // TODO: Update backend setting
        }
    }
    
    public var isPublicChannel: Bool {
        return channel.channelType == .broadcast
    }

    public required init(channel: ChatChannel) {
        self.channel = channel
        super.init()
    }
}
