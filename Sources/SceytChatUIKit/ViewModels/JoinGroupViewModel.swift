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

open class JoinGroupViewModel: DataProvider {
    
    public let inviteLink: String
    @Published public var channel: ChatChannel?
    
    @Published public var event: Event?
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var isJoining = false
    
    /// Indicates whether the controller should be dismissed when an error occurs
    /// This is true when channel info loading fails (channel is nil)
    public var shouldDismissOnError: Bool {
        return channel == nil
    }
    
    public required init(inviteLink: String) {
        self.inviteLink = inviteLink
        super.init()
    }
    
    public func loadChannelInfo() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        // Extract channel URI from invite link
        guard let key = extractChannelUri(from: inviteLink) else {
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.error = JoinGroupError.invalidLink
            }
            return
        }
        
        ChatClient.shared.getChannel(inviteKey: key) { [weak self] channel, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let channel = channel {
                    let ch = ChatChannel(channel: channel)
                    self?.channel = ch
                    self?.event = .channelLoaded(ch)
                } else {
                    self?.error = error ?? JoinGroupError.invalidLink
                }
            }
        }
    }
    
    public func joinChannel() {
        guard let channel = channel, !isJoining else { return }
        guard let key = extractChannelUri(from: inviteLink) else { return }
        
        isJoining = true
        error = nil
        
        ChatClient.shared.joinChannel(inviteKey: key) { [weak self] channel, error in
            guard let self = self else { return }
            self.isJoining = false
            if let error = error {
                self.error = error
            } else {
                if let channel = channel {
                    let ch = ChatChannel(channel: channel)
                    // Write channel to database
                    self.database.write {
                        $0.createOrUpdate(channel: channel)
                    } completion: { error in
                        logger.errorIfNotNil(error, "Store joined channel in db")
                    }
                    
                    self.joinedChannelHandler()
                    self.event = .joinedChannel(ch)
                }
            }
        }
    }
    
    open func joinedChannelHandler() {}
    
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
