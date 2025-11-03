//
//  PollViewModel.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 03.11.25.
//

/// UI model for displaying poll in the view
public struct PollViewModel {
    let pollId: String
    let question: String
    let pollTypeText: String
    let options: [PollOptionViewModel]
    let totalVotes: Int
    let closed: Bool
    let anonymous: Bool
    let allowMultipleVotes: Bool
    let allowVoteRetract: Bool

    init(from poll: PollDetails) {
        self.pollId = poll.id
        self.question = poll.name
        self.closed = poll.closed
        self.anonymous = poll.anonymous
        self.allowMultipleVotes = poll.allowMultipleVotes
        self.allowVoteRetract = poll.allowVoteRetract
        self.totalVotes = poll.votesPerOption.values.reduce(0, +)

        let maxVotes = poll.votesPerOption.values.max() ?? 0
        let currentUserId = SceytChatUIKit.shared.currentUserId
        self.options = poll.options.map { option in
            // Priority 1: Check pending votes first (optimistic UI)
            let selected: Bool
            if let pendingVotes = poll.pendingVotes,
               let userId = currentUserId {
                // Filter pending votes for this option and current user, sorted by creation time
                let relevantPendingVotes = pendingVotes
                    .filter { $0.optionId == option.id && $0.userId == userId }
                    .sorted { $0.createdAt > $1.createdAt }
                
                if let latestPendingVote = relevantPendingVotes.first {
                    // Latest pending vote determines selection state
                    selected = latestPendingVote.isAdd
                } else {
                    // No pending votes, fall back to ownVotes
                    selected = poll.ownVotes.contains(where: { option.id == $0.optionId })
                }
            } else {
                // No pending votes available, use ownVotes
                selected = poll.ownVotes.contains(where: { option.id == $0.optionId })
            }
            
            let voters = poll.votes
                .filter( { $0.optionId == option.id })
                .compactMap (\.user)

            let votesCount = poll.votesPerOption[option.id] ?? 0
            let progress = votesCount > 0 ? Float(votesCount) / Float(maxVotes) : 0.0

            return PollOptionViewModel(
                id: option.id,
                text: option.text,
                voteCount: votesCount ,
                progress: progress,
                selected: selected,
                isAnonymous: poll.anonymous,
                voters: voters
            )
        }

        // TODO: - Remove
        if poll.anonymous {
            self.pollTypeText = "Anonymous poll"
        } else {
            self.pollTypeText = "Public poll"
        }
    }
}
