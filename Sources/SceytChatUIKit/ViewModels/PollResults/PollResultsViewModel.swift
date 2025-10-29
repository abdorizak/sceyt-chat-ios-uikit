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

    @Published public var pollResults: PollResultsModel
    @Published public var event: Event?
    @Published public var isLoading = false
    @Published public var error: Error?

    public required init(pollResults: PollResultsModel = PollResultsModel()) {
        self.pollResults = pollResults
        super.init()
    }

    // MARK: - Computed Properties

    public var numberOfOptions: Int {
        pollResults.options.count
    }

    public func option(at index: Int) -> PollOptionResult? {
        guard index < pollResults.options.count else { return nil }
        return pollResults.options[index]
    }

    public func numberOfVoters(for optionIndex: Int) -> Int {
        guard let option = option(at: optionIndex) else { return 0 }
        return option.voters.count
    }

    public func shouldShowMoreButton(for optionIndex: Int) -> Bool {
        guard let option = option(at: optionIndex) else { return false }
        return option.voteCount > option.voters.count
    }

    public func showMoreVoters(for optionIndex: Int) {
        guard let option = option(at: optionIndex) else { return }
        let totalVotes = pollResults.options.reduce(0) { $0 + $1.voteCount }
        event = .showOptionDetail(
            option: option,
            questionText: pollResults.question,
            totalVotes: totalVotes
        )
    }
}

public extension PollResultsViewModel {
    enum Event {
        case reloadData
        case showOptionDetail(option: PollOptionResult, questionText: String, totalVotes: Int)
    }
}
