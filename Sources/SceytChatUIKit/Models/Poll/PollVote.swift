//
//  PollVote.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 03.11.25.
//

import Foundation

public struct PollVote {
    public let pollId: String
    public let optionId: String
    public let userId: String
    public let createdAt: Int64
    public let user: ChatUser?
}

// MARK: - init with DTO

extension PollVote {
    init(dto: PollVoteDTO) {
        self.pollId = dto.pollDetails?.id ?? dto.ownPollDetails?.id ?? ""
        self.optionId = dto.optionId
        self.userId = dto.user?.id ?? ""
        if let user = dto.user {
            self.user = ChatUser(dto: user)
        } else {
            self.user = nil
        }
        self.createdAt = dto.createdAt
    }
}

// MARK: - PollVoterRepresentable

extension PollVote: PollVoterRepresentable {
    public var createdAtDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
}
