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

    public init(
        pollId: String,
        question: String,
        pollTypeText: String,
        options: [PollOptionViewModel],
        totalVotes: Int,
        closed: Bool,
        anonymous: Bool,
        allowMultipleVotes: Bool,
        allowVoteRetract: Bool
    ) {
        self.pollId = pollId
        self.question = question
        self.pollTypeText = pollTypeText
        self.options = options
        self.totalVotes = totalVotes
        self.closed = closed
        self.anonymous = anonymous
        self.allowMultipleVotes = allowMultipleVotes
        self.allowVoteRetract = allowVoteRetract
    }

    public init(from poll: PollDetails, isIncmoing: Bool) {
        self.pollId = poll.id
        self.question = poll.name
        self.closed = poll.closed
        self.anonymous = poll.anonymous
        self.allowMultipleVotes = poll.allowMultipleVotes
        self.allowVoteRetract = poll.allowVoteRetract
        
        let currentUserId = SceytChatUIKit.shared.currentUserId
        let isSinglePoll = !poll.allowMultipleVotes

        // For single polls: find the latest pending vote across ALL options
        let latestPendingVoteOptionId: String? = {
            guard isSinglePoll,
                  let pendingVotes = poll.pendingVotes,
                  let userId = currentUserId else {
                return nil
            }

            // Get all pending votes for current user, sorted by creation time
            let userPendingVotes = pendingVotes
                .filter { $0.userId == userId }
                .sorted { $0.createdAt > $1.createdAt }

            // Return the option ID of the latest pending vote if it's an add
            return userPendingVotes.first?.isAdd == true ? userPendingVotes.first?.optionId : nil
        }()

        // Calculate adjusted votes per option considering pending votes
        var adjustedVotesPerOption = poll.votesPerOption
        
        // Apply pending vote adjustments for optimistic UI
        if let pendingVotes = poll.pendingVotes, let userId = currentUserId {
            if isSinglePoll {
                // For single poll: only apply the latest pending vote
                if let latestPendingVoteOptionId = latestPendingVoteOptionId {
                    // Remove vote from previously voted option (if any)
                    if let previousOwnVote = poll.ownVotes.first {
                        let currentCount = poll.votesPerOption[previousOwnVote.optionId] ?? 0
                        adjustedVotesPerOption[previousOwnVote.optionId] = max(0, currentCount - 1)
                    }

                    // Add vote to the pending vote option
                    let currentCount = poll.votesPerOption[latestPendingVoteOptionId] ?? 0
                    let wasVotedInServer = poll.ownVotes.contains(where: { $0.optionId == latestPendingVoteOptionId })
                    if !wasVotedInServer {
                        adjustedVotesPerOption[latestPendingVoteOptionId] = currentCount + 1
                    }
                }
            } else {
                // For multiple polls: apply pending votes per option
                for option in poll.options {
                    let relevantPendingVotes = pendingVotes
                        .filter { $0.optionId == option.id && $0.userId == userId }
                        .sorted { $0.createdAt > $1.createdAt }

                    if let latestPendingVote = relevantPendingVotes.first {
                        let wasVotedInServer = poll.ownVotes.contains(where: { $0.optionId == option.id })
                        let currentCount = poll.votesPerOption[option.id] ?? 0

                        if latestPendingVote.isAdd && !wasVotedInServer {
                            adjustedVotesPerOption[option.id] = currentCount + 1
                        } else if !latestPendingVote.isAdd && wasVotedInServer {
                            adjustedVotesPerOption[option.id] = max(0, currentCount - 1)
                        }
                    }
                }
            }
        }
        
        self.totalVotes = adjustedVotesPerOption.values.reduce(0, +)
        let maxVotes = adjustedVotesPerOption.values.max() ?? 0
        
        self.options = poll.options.map { option in
            // Priority 1: Check pending votes first (optimistic UI)
            let selected: Bool
            if isSinglePoll {
                // Single poll logic: pending vote has absolute priority
                if let latestPendingVoteOptionId = latestPendingVoteOptionId {
                    // Show ONLY the pending vote, ignore ownVotes completely
                    selected = option.id == latestPendingVoteOptionId
                } else {
                    // No pending vote, fall back to ownVotes
                    selected = poll.ownVotes.contains(where: { option.id == $0.optionId })
                }
            } else if let pendingVotes = poll.pendingVotes,
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

            var voters = poll.votes
                .filter( { $0.optionId == option.id })
                .compactMap (\.user)

            // Append current user if they selected this option (considering pending votes) and not already in voters array
            if selected, let currentUserId = currentUserId {
                let currentUserInVoters = voters.contains(where: { $0.id == currentUserId })
                if !currentUserInVoters {
                    let currentUser = ChatUser(user: SceytChatUIKit.shared.chatClient.user)
                    voters.append(currentUser)
                }
            } else if !selected, let currentUserId = currentUserId {
                // Remove current user from voters if they unvoted (pending removal)
                voters.removeAll(where: { $0.id == currentUserId })
            }

            let votesCount = adjustedVotesPerOption[option.id] ?? 0
            let progress = votesCount > 0 ? Float(votesCount) / Float(maxVotes) : 0.0

            return PollOptionViewModel(
                id: option.id,
                text: option.text,
                voteCount: votesCount,
                progress: progress,
                selected: selected,
                isAnonymous: poll.anonymous,
                isIncoming: isIncmoing,
                isClosed: poll.closed,
                voters: voters
            )
        }

        self.pollTypeText = SceytChatUIKit.shared.formatters.pollTypeFormatter.format((closed: poll.closed, anonymous: poll.anonymous, isSingle: !poll.allowMultipleVotes))
    }
}
