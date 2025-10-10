//
//  ChannelInviteLinkViewModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat
import Combine

open class ChannelInviteLinkViewModel: NSObject {

    public let channel: ChatChannel
    public var channelInviteKey: SCTChannelInviteKey?
    
    @Published public var event: Event?
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var showPreviousMessages: Bool = false

    public var inviteLink: String? {
        guard let config = SceytChatUIKit.shared.config.channelInviteDeepLinkConfig else {
            return nil
        }
        return config.constructInviteLink(for: channel.uri)
    }
    
    public var isPublicChannel: Bool {
        return channel.channelType == .broadcast
    }

    public required init(channel: ChatChannel) {
        self.channel = channel
        super.init()
    }
    
    public func loadInviteLinkData() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        SceytChatUIKit.shared.chatClient.getChannelInviteKey(
            channelId: "\(channel.id)",
            key: channel.uri
        ) { [weak self] key, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                } else if let key = key {
                    self?.channelInviteKey = key
                    self?.showPreviousMessages = key.accessPriorHistory
                }
            }
        }
    }
    
    // MARK: - Reset Link
    
    public func updateShowPreviousMessages(_ value: Bool) {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        guard let inviteKey = channelInviteKey else { return }
        
        SceytChatUIKit.shared.chatClient.updateChannelInviteKey(
            channelId: "\(channel.id)",
            key: inviteKey.key,
            maxUses: Int(inviteKey.maxUses),
            expiresAt: TimeInterval(inviteKey.expiresAt),
            accessPriorHistory: value
        ) { [weak self] inviteKey, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                } else if let inviteKey = inviteKey {
                    self.channelInviteKey = inviteKey
                    self.showPreviousMessages = inviteKey.accessPriorHistory
                }
            }
        }
    }
    
    public func resetLink() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        SceytChatUIKit.shared.chatClient.regenerateChannelInviteKey(
            channelId: "\(channel.id)", 
            key: channel.uri
        ) { [weak self] newKey, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                } else if let newKey = newKey {
                    // Create a new channel instance with the updated URI
                    SceytChatUIKit.shared.database.write { [weak self] in
                        guard let self = self else { return }
                        ChannelDTO.fetchOrCreate(id: channel.id, context: $0)
                            .0.uri = newKey.key
                    } completion: { [weak self] _ in
                        DispatchQueue.main.async {
                            self?.event = .reloadData
                        }
                    }
                }
            }
        }
    }
}

public extension ChannelInviteLinkViewModel {
    enum Event {
        case reloadData
    }
}
