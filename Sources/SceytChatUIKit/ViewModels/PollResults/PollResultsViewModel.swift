//
//  PollResultsViewModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import Combine

open class PollResultsViewModel: NSObject {

    @Published public var pollResults: PollDetails
    @Published public var event: Event?
    @Published public var isLoading = false
    @Published public var error: Error?

    public required init(pollResults: PollDetails) {
        self.pollResults = pollResults
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
    
    // TODO: Check this condition logic
    public func voters(for optionIndex: Int) -> [PollVoterRepresentable] {
        guard let option = option(at: optionIndex) else { return [] }
        
        // Combine both ownVotes and votes
        let allVotes = pollResults.ownVotes + pollResults.votes

        // Filter votes belonging to this option
        return allVotes.filter { $0.optionId == option.id }
    }

    public func numberOfVoters(for optionIndex: Int) -> Int {
        return voters(for: optionIndex).count
    }

    public func shouldShowMoreButton(for optionIndex: Int) -> Bool {
        guard let option = option(at: optionIndex) else { return false }
        return option.voteCount > numberOfVoters(for: optionIndex)
    }

    public func showMoreVoters(for optionIndex: Int) {
        guard let option = option(at: optionIndex) else { return }
        let totalVotes = pollResults.options.reduce(0) { $0 + $1.voteCount }
        event = .showOptionDetail(
            option: option,
            pollDetails: pollResults,
            questionText: pollResults.name,
            totalVotes: totalVotes
        )
    }
}

public extension PollResultsViewModel {
    enum Event {
        case reloadData
        case showOptionDetail(option: PollOption, pollDetails: PollDetails, questionText: String, totalVotes: Int)
    }
}
