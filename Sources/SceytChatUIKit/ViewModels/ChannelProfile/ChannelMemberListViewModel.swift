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
    
    public lazy var defaultPredicate: NSPredicate = {
        var predicate = NSPredicate(format: "channelId == %lld", channel.id)
        if let filterMembersByRole {
            predicate = predicate.and(predicate: .init(format: "role.name == %@", filterMembersByRole))
        }
        return predicate
    }()

    // Separate observers for each role section
    public private(set) lazy var ownerObserver: DatabaseObserver<MemberDTO, ChatChannelMember> = {
        let predicate = NSPredicate(format: "channelId == %lld AND role.name == %@",
                                   channel.id,
                                   SceytChatUIKit.shared.config.memberRolesConfig.owner)
        return DatabaseObserver<MemberDTO, ChatChannelMember>(
            request: MemberDTO.fetchRequest()
                .fetch(predicate: predicate)
                .sort(descriptors: []),
            context: SceytChatUIKit.shared.database.viewContext
        ) { $0.convert() }
    }()

    public private(set) lazy var adminObserver: DatabaseObserver<MemberDTO, ChatChannelMember> = {
        let predicate = NSPredicate(format: "channelId == %lld AND role.name == %@",
                                   channel.id,
                                   SceytChatUIKit.shared.config.memberRolesConfig.admin)
        return DatabaseObserver<MemberDTO, ChatChannelMember>(
            request: MemberDTO.fetchRequest()
                .fetch(predicate: predicate)
                .sort(descriptors: []),
            context: SceytChatUIKit.shared.database.viewContext
        ) { $0.convert() }
    }()

    public private(set) lazy var otherObserver: DatabaseObserver<MemberDTO, ChatChannelMember> = {
        let ownerRole = SceytChatUIKit.shared.config.memberRolesConfig.owner
        let adminRole = SceytChatUIKit.shared.config.memberRolesConfig.admin
        let predicate = NSPredicate(format: "channelId == %lld AND role.name != %@ AND role.name != %@",
                                   channel.id,
                                   ownerRole,
                                   adminRole)
        return DatabaseObserver<MemberDTO, ChatChannelMember>(
            request: MemberDTO.fetchRequest()
                .fetch(predicate: predicate)
                .sort(descriptors: []),
            context: SceytChatUIKit.shared.database.viewContext
        ) { $0.convert() }
    }()

    public private(set) lazy var memberObserver: DatabaseObserver<MemberDTO, ChatChannelMember> = {
        return DatabaseObserver<MemberDTO, ChatChannelMember>(
            request: MemberDTO.fetchRequest()
                .fetch(predicate: defaultPredicate)
                .sort(descriptors: []),
            context: SceytChatUIKit.shared.database.viewContext
        ) { $0.convert() }
    }()

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

    open func startDatabaseObserver() {
        if shouldShowOnlyAdmins {
            // Wait for deletion to complete before starting observer
            deleteAdminsFromDatabase { [weak self] error in
                guard let self else { return }
                if let error = error {
                    logger.errorIfNotNil(error, "Failed to delete admins before starting observer")
                }

                // Use the original single observer when filtering by role
                self.memberObserver.onDidChange = { [weak self] in
                    self?.onDidChangeEvent(items: $0)
                }
                do {
                    try self.memberObserver.startObserver()
                } catch {
                    logger.errorIfNotNil(error, "observer.startObserver")
                }

                self.loadMembers()
            }
        } else {
            // Wait for deletion to complete before starting observers
            deleteMembersFromDatabase { [weak self] error in
                guard let self else { return }
                if let error = error {
                    logger.errorIfNotNil(error, "Failed to delete members before starting observer")
                }

                // Use separate observers for each role section
                self.ownerObserver.onDidChange = { [weak self] in
                    guard let self else { return }
                    self.onDidChangeEvent(items: $0, section: self.ownerSectionIndex)
                }
                self.adminObserver.onDidChange = { [weak self] in
                    guard let self else { return }
                    self.onDidChangeEvent(items: $0, section: self.adminSectionIndex)
                }
                self.otherObserver.onDidChange = { [weak self] in
                    guard let self else { return }
                    self.onDidChangeEvent(items: $0, section: self.otherSectionIndex)
                }
                do {
                    try self.ownerObserver.startObserver()
                    try self.adminObserver.startObserver()
                    try self.otherObserver.startObserver()
                } catch {
                    logger.errorIfNotNil(error, "observer.startObserver")
                }

                self.loadMembers()
            }
        }
    }

    open func deleteMembersFromDatabase(completion: ((Error?) -> Void)? = nil) {
        provider.database.write { context in
            let predicate = NSPredicate(format: "channelId == %lld", self.channel.id)
            context.deleteMembers(predicate: predicate)
        } completion: { error in
            if let error = error {
                logger.errorIfNotNil(error, "Failed to delete members from database")
            }
            completion?(error)
        }
    }

    open func deleteAdminsFromDatabase(completion: ((Error?) -> Void)? = nil) {
        provider.database.write { context in
            let predicate = NSPredicate(format: "channelId == %lld AND role.name == %@",
                                       self.channel.id,
                                       SceytChatUIKit.shared.config.memberRolesConfig.admin)
            context.deleteMembers(predicate: predicate)
        } completion: { error in
            if let error = error {
                logger.errorIfNotNil(error, "Failed to delete admins from database")
            }
            completion?(error)
        }
    }

    open var shouldShowOnlyAdmins: Bool {
        filterMembersByRole == SceytChatUIKit.shared.config.memberRolesConfig.admin
    }
    
    open func onDidChangeEvent(items: DBChangeItemPaths, section: Int? = nil) {
        if let section = section {
            // Role-based section change
            event = .change(.init(changes: items, section: section))
        } else {
            // Original behavior for filtered view
            event = .change(.init(changes: items, section: hasActionRows ? 1 : 0))
        }
    }

    // Section indices for role-based display
    open var ownerSectionIndex: Int {
        hasActionRows ? 1 : 0
    }

    open var adminSectionIndex: Int {
        hasActionRows ? 2 : 1
    }

    open var otherSectionIndex: Int {
        hasActionRows ? 3 : 2
    }

    open func member(at indexPath: IndexPath) -> ChatChannelMember? {
        if shouldShowOnlyAdmins {
            // Use original observer when filtering
            return memberObserver.item(at: .init(row: indexPath.row, section: 0))
        } else {
            // Use role-specific observers
            let section = indexPath.section
            if section == ownerSectionIndex {
                return ownerObserver.item(at: .init(row: indexPath.row, section: 0))
            } else if section == adminSectionIndex {
                return adminObserver.item(at: .init(row: indexPath.row, section: 0))
            } else if section == otherSectionIndex {
                return otherObserver.item(at: .init(row: indexPath.row, section: 0))
            }
            return nil
        }
    }
    
    open var numberOfSections: Int {
        if shouldShowOnlyAdmins {
            // Original behavior when filtering
            return hasActionRows ? 2 : 1
        } else {
            // Role-based sections: action rows (optional) + owners + admins + others
            return hasActionRows ? 4 : 3
        }
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
        if shouldShowOnlyAdmins {
            // Original behavior when filtering
            switch (section, hasActionRows) {
            case (0, true):
                return numberOfActionRows
            case (1, true), (0, false):
                return memberObserver.numberOfItems(in: 0)
            default:
                return 0
            }
        } else {
            // Role-based sections
            if section == 0 && hasActionRows {
                return numberOfActionRows
            } else if section == ownerSectionIndex {
                return ownerObserver.numberOfItems(in: 0)
            } else if section == adminSectionIndex {
                return adminObserver.numberOfItems(in: 0)
            } else if section == otherSectionIndex {
                return otherObserver.numberOfItems(in: 0)
            }
            return 0
        }
    }
    
    var numberOfMembers: Int {
        if shouldShowOnlyAdmins {
            return memberObserver.numberOfItems(in: 0)
        } else {
            return ownerObserver.numberOfItems(in: 0) +
                   adminObserver.numberOfItems(in: 0) +
                   otherObserver.numberOfItems(in: 0)
        }
    }

    open func loadMembers() {
        provider.loadMembers()
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
        channelProvider
            .kick(
                members: [member.id],
                completion: completion
            )
    }

    open func block(memberAt indexPath: IndexPath, completion: @escaping (Error?) -> Void) {
        guard let member = member(at: indexPath) else { return }
        channelProvider
            .block(
                members: [member.id],
                completion: completion
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
