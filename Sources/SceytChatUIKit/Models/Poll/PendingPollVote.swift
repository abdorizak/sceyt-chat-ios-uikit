//
//  PendingPollVote.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 03.11.25.
//

import Foundation

public struct PendingPollVote {
    public let messageTid: Int64
    public let pollId: String
    public let optionId: String
    public let userId: String
    public let isAdd: Bool // true = add vote, false = remove vote
    public let createdAt: Int64
    public let user: ChatUser?
}

// MARK: - init with DTO

extension PendingPollVote {
    init(dto: PendingVoteDTO) {
        self.messageTid = dto.messageTid
        self.pollId = dto.pollId ?? ""
        self.optionId = dto.optionId ?? ""
        self.userId = dto.user?.id ?? ""
        self.isAdd = dto.isAdd
        self.createdAt = dto.createdAt
        if let user = dto.user {
            self.user = ChatUser(dto: user)
        } else {
            self.user = nil
        }
    }
}

// MARK: - PollVoterRepresentable

extension PendingPollVote: PollVoterRepresentable {
    public var createdAtDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
}
