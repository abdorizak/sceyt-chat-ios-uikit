//
//  Poll.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 28.10.25.
//

import Foundation
import SceytChat

public struct PollDetails {
    let id: String
    let name: String
    let messageTid: Int64
    let description: String
    let options: [PollOption]
    let anonymous: Bool
    let allowMultipleVotes: Bool
    let allowVoteRetract: Bool
    let votesPerOption: [String: Int]
    let votes: [PollVote]
    let ownVotes: [PollVote]
    let pendingVotes: [PendingPollVote]?
    let createdAt: Int64
    let updatedAt: Int64
    let closedAt: Int64
    let closed: Bool
}

public struct PollOption {
    let id: String
    let text: String
    let voteCount: Int
    let voters: [ChatUser]
    let pendingVote: PendingPollVote
    let selected: Bool

    func percentage(totalVotes: Int) -> Float {
        guard totalVotes > 0 else { return 0 }
        return (Float(voteCount) / Float(totalVotes)) * 100
    }
}

public struct PendingPollVote {
    let messageTid: Int64
    let pollId: String
    let optionId: String
    let userId: String
    let isAdd: Bool // true = add vote, false = remove vote
    let createdAt: Int64
}

public struct PollVote: Codable {
    let pollId: String
    let optionId: String
    let userId: String
    let createdAt: Int64
}

// MARK: - Initializers from DTO

extension PollDetails {
    init(dto: PollDTO) {
        self.id = dto.id
        self.name = dto.name ?? ""
        self.messageTid = dto.messageTid
        self.description = dto.pollDescription ?? ""
        self.options = (dto.options?.allObjects as? [PollOptionDTO])?.map { PollOption(dto: $0, pollDTO: dto) } ?? []
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
        
        self.votes = (dto.votes?.allObjects as? [PollVoteDTO])?.map { PollVote(dto: $0) } ?? []
        self.ownVotes = (dto.ownVotes?.allObjects as? [PollVoteDTO])?.map { PollVote(dto: $0) } ?? []
        
        // Fetch pending votes for this poll
        if let context = dto.managedObjectContext {
            let pendingVoteDTOs = PendingVoteDTO.fetch(messageTid: dto.messageTid, context: context)
            self.pendingVotes = pendingVoteDTOs.map { PendingPollVote(dto: $0) }
        } else {
            self.pendingVotes = nil
        }
        
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.closedAt = dto.closedAt
        self.closed = dto.closed
    }
}

extension PollOption {
    init(dto: PollOptionDTO, pollDTO: PollDTO) {
        self.id = dto.id
        self.text = dto.name ?? ""
        
        // Get vote count from poll's votesPerOption
        let votesDict = pollDTO.votesPerOption as? [String: NSNumber] ?? [:]
        self.voteCount = votesDict[dto.id]?.intValue ?? 0
        
        // Get voters from votes that match this option
        let allVotes = (pollDTO.votes?.allObjects as? [PollVoteDTO]) ?? []
        let optionVotes = allVotes.filter { $0.optionId == dto.id }
        self.voters = optionVotes.compactMap { voteDTO in
            guard let userDTO = voteDTO.user else { return nil }
            return ChatUser(dto: userDTO)
        }
        
        // Check if there's a pending vote for this option
        if let context = dto.managedObjectContext {
            let pendingVoteDTOs = PendingVoteDTO.fetch(messageTid: pollDTO.messageTid, context: context)
            if let pendingVote = pendingVoteDTOs.first(where: { $0.optionId == dto.id }) {
                self.pendingVote = PendingPollVote(dto: pendingVote)
            } else {
                self.pendingVote = PendingPollVote(messageTid: pollDTO.messageTid, pollId: pollDTO.id, optionId: dto.id, userId: "", isAdd: false, createdAt: 0)
            }
        } else {
            self.pendingVote = PendingPollVote(messageTid: pollDTO.messageTid, pollId: pollDTO.id, optionId: dto.id, userId: "", isAdd: false, createdAt: 0)
        }
        
        // Check if current user has voted for this option
        let ownVotes = (pollDTO.ownVotes?.allObjects as? [PollVoteDTO]) ?? []
        self.selected = ownVotes.contains(where: { $0.optionId == dto.id })
    }
}

extension PollVote {
    init(dto: PollVoteDTO) {
        self.pollId = dto.pollDetails?.id ?? dto.ownPollDetails?.id ?? ""
        self.optionId = dto.optionId
        self.userId = dto.user?.id ?? ""
        self.createdAt = dto.createdAt
    }
}

extension PendingPollVote {
    init(dto: PendingVoteDTO) {
        self.messageTid = dto.messageTid
        self.pollId = dto.pollId ?? ""
        self.optionId = dto.optionId ?? ""
        self.userId = dto.user?.id ?? ""
        self.isAdd = dto.isAdd
        self.createdAt = dto.createdAt
    }
}
