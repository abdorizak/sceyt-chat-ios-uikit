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

    open func loadMembers() {
        if !hasNext || query.loading {
            return
        }
        query.loadNext { _, members, _ in
            if (members?.count ?? 0) < Int(self.queryLimit) {
                self.hasNext = false
            }
            guard let members = members,
                  !members.isEmpty
            else { return }
            
            self.store(members: members)
        }
    }

    open func store(members: [Member]) {
        database.write {
            $0.createOrUpdate(
                members: members, channelId: self.channelId)
        } completion: { error in
            logger.debug(error?.localizedDescription ?? "")
        }
    }
}
