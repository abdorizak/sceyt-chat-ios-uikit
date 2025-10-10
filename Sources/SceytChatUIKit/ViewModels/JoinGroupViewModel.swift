//
//  JoinGroupViewModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat
import Combine

open class JoinGroupViewModel: NSObject {
    
    public let inviteLink: String
    public var channel: ChatChannel?
    
    @Published public var event: Event?
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var isJoining = false
    
    public required init(inviteLink: String) {
        self.inviteLink = inviteLink
        super.init()
    }
    
    public func loadChannelInfo() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        // Extract channel URI from invite link
        guard let channelUri = extractChannelUri(from: inviteLink) else {
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.error = JoinGroupError.invalidLink
            }
            return
        }
        
        ChannelProvider.getChannelByURI(channelUri) { [weak self] channel, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.error = error
                } else if let channel = channel {
                    self?.channel = channel
                    self?.event = .channelLoaded(channel)
                }
            }
        }
    }
    
    public func joinChannel() {
        guard let channel = channel, !isJoining else { return }
        
        isJoining = true
        error = nil
        
        ChannelProvider(channelId: channel.id).join { [weak self] err in
            guard let self = self else { return }
            self.isJoining = false
            if let error = error {
                self.error = error
            } else {
                self.event = .joinedChannel(channel)
            }
        }
    }
    
    private func extractChannelUri(from link: String) -> String? {
        guard let config = SceytChatUIKit.shared.config.channelInviteDeepLinkConfig,
              let url = URL(string: link) else {
            return nil
        }

        // Check if the URL matches the configured scheme and host
        guard url.scheme == config.scheme,
              url.host == config.host else {
            return nil
        }

        // Extract the path and check if it starts with the configured pathPrefix
        let path = url.path
        guard path.hasPrefix(config.pathPrefix) else {
            return nil
        }

        // Extract the channel URI by removing the pathPrefix
        let channelUri = String(path.dropFirst(config.pathPrefix.count))
        return channelUri.isEmpty ? nil : channelUri
    }
}

public extension JoinGroupViewModel {
    enum Event {
        case channelLoaded(ChatChannel)
        case joinedChannel(ChatChannel)
    }
    
    enum JoinGroupError: LocalizedError {
        case invalidLink
        
        public var errorDescription: String? {
            switch self {
            case .invalidLink:
                return "Invalid invite link"
            }
        }
    }
}
