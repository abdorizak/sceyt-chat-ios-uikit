//
//  PollResultsViewModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import Combine
import SceytChat

open class PollResultsViewModel: NSObject {

    @Published public var pollResults: PollDetails
    @Published public var event: Event?
    @Published public var isLoading = false
    @Published public var error: Error?

    public let messageID: MessageId

    public required init(pollResults: PollDetails, messageID: MessageId) {
        self.pollResults = pollResults
        self.messageID = messageID
        super.init()
    }

    // MARK: - Computed Properties
    
    public var numberOfOptions: Int {
        pollResults.options.count
    }

    public func option(at index: Int) -> PollOption? {
        guard index < pollResults.options.count else { return nil }
        return pollResults.options[index]
    }
    
    public func voters(for optionIndex: Int) -> [PollVoterRepresentable] {
        guard let option = option(at: optionIndex) else { return [] }
        
        var ownVotes: [PollVoterRepresentable] = []
        if let pending = pollResults.pendingVotes?.first(where: { $0.optionId == option.id }) {
            ownVotes = [pending]
        } else {
            ownVotes = pollResults.ownVotes
        }
        
        // Combine both ownVotes and votes
        let allVotes = ownVotes + pollResults.votes

        // Filter votes belonging to this option
        return allVotes.filter { $0.optionId == option.id }
    }

    public func numberOfVoters(for optionIndex: Int) -> Int {
        return voters(for: optionIndex).count
    }

    public func shouldShowMoreButton(for optionIndex: Int) -> Bool {
        return true
        guard let option = option(at: optionIndex) else { return false }
        let voteCount = pollResults.votesPerOption[option.id] ?? 0
        return voteCount > numberOfVoters(for: optionIndex)
    }

    public func showMoreVoters(for optionIndex: Int) {
        guard let option = option(at: optionIndex) else { return }
        event = .showOptionDetail(
            option: option,
            pollDetails: pollResults,
            messageID: messageID
        )
    }
}

public extension PollResultsViewModel {
    enum Event {
        case reloadData
        case showOptionDetail(option: PollOption, pollDetails: PollDetails, messageID: MessageId)
    }
}
