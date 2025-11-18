//
//  PollDetails.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 03.11.25.
//

import SceytChat
import Foundation

public struct PollDetails {
    public let id: String
    public let name: String
    public let messageTid: Int64
    public let description: String
    public let options: [PollOption]
    public let anonymous: Bool
    public let allowMultipleVotes: Bool
    public let allowVoteRetract: Bool
    public let votesPerOption: [String: Int]
    public let votes: [PollVote]
    public let ownVotes: [PollVote]
    public let pendingVotes: [PendingPollVote]?
    public let createdAt: Int64
    public let updatedAt: Int64
    public let closedAt: Int64
    public let closed: Bool
    
    public init(
        id: String,
        name: String,
        messageTid: Int64,
        description: String,
        options: [PollOption],
        anonymous: Bool,
        allowMultipleVotes: Bool,
        allowVoteRetract: Bool,
        votesPerOption: [String: Int],
        votes: [PollVote],
        ownVotes: [PollVote],
        pendingVotes: [PendingPollVote]?,
        createdAt: Int64,
        updatedAt: Int64,
        closedAt: Int64,
        closed: Bool
    ) {
        self.id = id
        self.name = name
        self.messageTid = messageTid
        self.description = description
        self.options = options
        self.anonymous = anonymous
        self.allowMultipleVotes = allowMultipleVotes
        self.allowVoteRetract = allowVoteRetract
        self.votesPerOption = votesPerOption
        self.votes = votes
        self.ownVotes = ownVotes
        self.pendingVotes = pendingVotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.closedAt = closedAt
        self.closed = closed
    }
}

extension PollDetails {
    init(dto: PollDTO) {
        self.id = dto.id
        self.name = dto.name ?? ""
        self.messageTid = dto.messageTid
        self.description = dto.pollDescription ?? ""
        self.options = (dto.options?.array as? [PollOptionDTO])?.map { PollOption(dto: $0) } ?? []
        self.anonymous = dto.anonymous
        self.allowMultipleVotes = dto.allowMultipleVotes
        self.allowVoteRetract = dto.allowVoteRetract

        var votesDict: [String: Int] = [:]
        if let votesPerOption = dto.votesPerOption as? [String: NSNumber] {
            for (key, value) in votesPerOption {
                votesDict[key] = value.intValue
            }
        }

        self.votesPerOption = votesDict

        self.votes = (dto.votes?.array as? [PollVoteDTO])?.map { PollVote(dto: $0) } ?? []
        self.ownVotes = (dto.ownVotes?.array as? [PollVoteDTO])?.map { PollVote(dto: $0) } ?? []

        if let pendingVotesSet = dto.pendingVotes,
           let pendingVoteDTOs = pendingVotesSet.allObjects as? [PendingVoteDTO],
           !pendingVoteDTOs.isEmpty {
            self.pendingVotes = pendingVoteDTOs.map { PendingPollVote(dto: $0) }
        } else {
            self.pendingVotes = nil
        }

        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.closedAt = dto.closedAt
        self.closed = dto.closed
    }

    init(poll: SceytChat.PollDetails, messageTid: Int64, ownVotes: [PollVoteDTO]) {
        self.id = poll.id
        self.name = poll.name ?? ""
        self.messageTid = messageTid
        self.description = poll.pollDescription ?? ""
        self.options = poll.options.map { PollOption(id: $0.id, text: $0.name) }
        self.anonymous = poll.anonymous
        self.allowMultipleVotes = poll.allowMultipleVotes
        self.allowVoteRetract = poll.allowVoteRetract
        self.pendingVotes = nil

        var votesDict: [String: Int] = [:]
        if let votesPerOption = poll.votesPerOption as? [String: NSNumber] {
            for (key, value) in votesPerOption {
                votesDict[key] = value.intValue
            }
        }

        self.votesPerOption = votesDict

        self.votes = poll.votes.map {
            PollVote(pollId: poll.id,
                     optionId: $0.optionId,
                     userId: $0.user.id,
                     createdAt: Int64($0.createdAt.timeIntervalSince1970),
                     user: ChatUser(user: $0.user)
            )
        }

        let currentUser = ChatClient.shared.user
        self.ownVotes = ownVotes.map {
            PollVote(dto: $0)
        }

        self.createdAt = Int64(poll.createdAt.timeIntervalSince1970)
        self.updatedAt = Int64(poll.updatedAt.timeIntervalSince1970)
        if let closedAt = poll.closedAt {
            self.closedAt = Int64(closedAt.timeIntervalSince1970)
        } else {
            self.closedAt = 0
        }

        self.closed = poll.closed
    }
}
