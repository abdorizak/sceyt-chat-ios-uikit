//
//  ChannelMemberListViewModel.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 26.10.23.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat
import Combine

open class ChannelMemberListViewModel: NSObject {

    public let channel: ChatChannel
    public let filterMembersByRole: String?
    public let provider: ChannelMemberListProvider
    public let channelProvider: ChannelProvider

    // Direct members array from server
    private var members: [ChatChannelMember] = []

    public var addTitle: String {
        if shouldShowOnlyAdmins {
            return L10n.Channel.Add.Admins.title
        } else if channel.channelType == .broadcast {
            return L10n.Channel.Add.Subscribers.title
        } else {
            return  L10n.Channel.Add.Members.title
        }
    }

    public var inviteLinkTitle: String {
        return L10n.Channel.InviteLink.title
    }
    
    public var addRole: String {
        if filterMembersByRole == SceytChatUIKit.shared.config.memberRolesConfig.admin {
            return SceytChatUIKit.shared.config.memberRolesConfig.admin
        } else if channel.channelType == .broadcast {
            return SceytChatUIKit.shared.config.memberRolesConfig.subscriber
        } else {
            return SceytChatUIKit.shared.config.memberRolesConfig.participant
        }
    }
    
    @Published public var event: Event?

    public required init(channel: ChatChannel,
                         filterMembersByRole: String? = nil) {
        self.channel = channel
        self.filterMembersByRole = filterMembersByRole
        provider = Components.channelMemberListProvider.init(channelId: channel.id)
        channelProvider = Components.channelProvider.init(channelId: channel.id)
        super.init()
    }
    
    open var canAddMembers: Bool {
        switch channel.channelType {
        case .direct:
            return false
        case .group:
            if shouldShowOnlyAdmins {
                return channel.userRole == SceytChatUIKit.shared.config.memberRolesConfig.owner || channel.userRole == SceytChatUIKit.shared.config.memberRolesConfig.admin
            }
            return true
        default:
            return channel.userRole == SceytChatUIKit.shared.config.memberRolesConfig.owner || channel.userRole == SceytChatUIKit.shared.config.memberRolesConfig.admin
        }
    }

    open var canShowInviteLink: Bool {
        // Only show invite link if config is set and user can add members
        return canAddMembers && SceytChatUIKit.shared.config.channelInviteDeepLinkConfig != nil
    }

    open var shouldShowOnlyAdmins: Bool {
        filterMembersByRole == SceytChatUIKit.shared.config.memberRolesConfig.admin
    }

    open func member(at indexPath: IndexPath) -> ChatChannelMember? {
        guard indexPath.row < members.count else { return nil }
        return members[indexPath.row]
    }
    
    open var numberOfSections: Int {
        hasActionRows ? 2 : 1
    }

    open var hasActionRows: Bool {
        canAddMembers || canShowInviteLink
    }

    open var numberOfActionRows: Int {
        var count = 0
        if canAddMembers { count += 1 }
        if canShowInviteLink { count += 1 }
        return count
    }

    open func numberOfItems(section: Int) -> Int {
        switch (section, hasActionRows) {
        case (0, true):
            return numberOfActionRows
        case (1, true), (0, false):
            return members.count
        default:
            return 0

        }
    }
    
    var numberOfMembers: Int {
        members.count
    }

    open func loadMembers() {
        provider.loadMembers { [weak self] fetchedMembers in
            guard let self = self, fetchedMembers.count > 0 else { return }
            self.members.append(contentsOf: fetchedMembers)
            self.event = .reload
        }
    }

    open func reloadMembers() {
        // Reset members array and reload from beginning
        members.removeAll()
        provider.reset()
        loadMembers()
    }

    open func loadNextPageIfNeeded() {
        guard provider.hasNext else { return }
        loadMembers()
    }

    open var hasMoreMembers: Bool {
        provider.hasNext
    }

    open func canChangeMemberRoleToOwner(memberAt indexPath: IndexPath) -> Bool {
        var isCurrentUserOwner: Bool {
            channel.userRole == "owner"
        }
        
        guard let member = member(at: indexPath) else { return false }
        return isCurrentUserOwner && member.id != SceytChatUIKit.shared.currentUserId
    }

    open func changeOwner(
        memberAt indexPath: IndexPath,
        completion: @escaping (Error?) -> Void) {
            guard let member = member(at: indexPath) else { return }
            channelProvider
                .changeOwner(
                    newOwnerId: member.id,
                    completion: completion
                )
        }

    open func kick(memberAt indexPath: IndexPath, completion: @escaping (Error?) -> Void) {
        guard let member = member(at: indexPath) else { return }
        let memberId = member.id
        channelProvider
            .kick(
                members: [memberId],
                completion: { [weak self] error in
                    guard let self else { return }
                    if error == nil {
                        // Remove member from local array after successful kick
                        // Find the actual index in the members array by ID (safer than relying on indexPath.row)
                        if let memberIndex = self.members.firstIndex(where: { $0.id == memberId }) {
                            self.members.remove(at: memberIndex)
                            
                            self.event = .reload
                        }
                    }
                    completion(error)
                }
            )
    }

    open func block(memberAt indexPath: IndexPath, completion: @escaping (Error?) -> Void) {
        guard let member = member(at: indexPath) else { return }
        let memberId = member.id
        channelProvider
            .block(
                members: [memberId],
                completion: { [weak self] error in
                    guard let self else { return }
                    if error == nil {
                        // Remove member from local array after successful block
                        if let memberIndex = self.members.firstIndex(where: { $0.id == memberId }) {
                            self.members.remove(at: memberIndex)
                            // Notify UI to update
                            self.event = .reload
                        }
                    }
                    completion(error)
                }
            )
    }

    open func setRole(
        name: String,
        memberAt indexPath: IndexPath,
        completion: @escaping (Error?) -> Void) {
            guard let member = member(at: indexPath) else { return }
            channelProvider.setRole(
                name: name,
                userId: member.id,
                completion: completion
            )
    }
    
    open func createChannel(userAt indexPath: IndexPath, completion: ((ChatChannel?, Error?) -> Void)? = nil) {
        guard let me = SceytChatUIKit.shared.currentUserId,
                let m = member(at: indexPath), m.id != me else {
            return
        }
        
        let members = [ChatChannelMember(user: m, roleName: SceytChatUIKit.shared.config.memberRolesConfig.owner),
                       ChatChannelMember(id: me, roleName: SceytChatUIKit.shared.config.memberRolesConfig.owner)]
        ChannelCreator()
            .createLocalChannelByMembers(type: SceytChatUIKit.shared.config.channelTypesConfig.direct,
                                members: members) { channel, error in
                completion?(channel, error)
            }
    }
}

public extension ChannelMemberListViewModel {

    enum Event {
        case reload
        case change(ChangeItemPaths)
    }
    
    struct ChangeItemPaths {
        
        public var inserts = [IndexPath]()
        public var updates = [IndexPath]()
        public var deletes = [IndexPath]()
        public var moves = [(from: IndexPath, to: IndexPath)]()
        
        public init(changes: DBChangeItemPaths, section: Int = 1) {
            
            inserts = changes.inserts.map { .init(row: $0.row, section: section) }
            updates = changes.updates.map { .init(row: $0.row, section: section) }
            deletes = changes.deletes.map { .init(row: $0.row, section: section) }
            moves = changes.moves.map { (.init(row: $0.from.row, section: section), .init(row: $0.to.row, section: section)) }
        }
    }
}
