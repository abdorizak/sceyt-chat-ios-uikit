//
//  ChannelMemberListProvider.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 26.10.23.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat

open class ChannelMemberListProvider: DataProvider {

    public var queryLimit = SceytChatUIKit.shared.config.queryLimits.channelMemberListQueryLimit
    public var queryOrder = MemberListOrder.username
    public var queryType = MemberListQueryType.all
    public var hasNext: Bool = true

    let channelId: ChannelId
    private var isLoading = false

    public required init(channelId: ChannelId) {
        self.channelId = channelId
        super.init()
    }

    open lazy var query: MemberListQuery = {
        .Builder(channelId: channelId)
        .order(queryOrder)
        .limit(UInt(queryLimit))
        .queryType(queryType)
        .build()
    }()

    /// Resets the provider to initial state for reloading from scratch
    open func reset() {
        hasNext = true
        isLoading = false
        query = .Builder(channelId: channelId)
            .order(queryOrder)
            .limit(UInt(queryLimit))
            .queryType(queryType)
            .build()
    }

    /// Loads next page of members from server
    open func loadMembers(completion: (([ChatChannelMember]) -> Void)? = nil) {
        guard !isLoading else {
            completion?([])
            return
        }
        guard hasNext else {
            completion?([])
            return
        }

        isLoading = true

        query.loadNext { [weak self] _, members, error in
            guard let self = self else {
                completion?([])
                return
            }

            self.isLoading = false

            if let error = error {
                logger.errorIfNotNil(error, "Failed to load members")
                completion?([])
                return
            }
            
            if (members?.count ?? 0) < queryLimit {
                hasNext = false
            }

            if let members = members {
                let chatMembers = members.map { ChatChannelMember(member: $0) }
                completion?(chatMembers)
            } else {
                completion?([])
            }
        }
    }
}
