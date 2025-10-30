//
//  PollOptionDetailViewModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import Combine
import SceytChat

open class PollOptionDetailViewModel: NSObject {

    @Published public var option: PollOption
    @Published public var pollDetails: PollDetails
    @Published public var questionText: String
    @Published public var totalVotes: Int
    @Published public var isLoading = false
    @Published public var error: Error?

    public required init(
        option: PollOption,
        pollDetails: PollDetails,
        questionText: String,
        totalVotes: Int
    ) {
        self.option = option
        self.pollDetails = pollDetails
        self.questionText = questionText
        self.totalVotes = totalVotes
        super.init()
    }

    // MARK: - Computed Properties

    public var numberOfVoters: Int {
        voters().count
    }

    public func voters() -> [PollVote] {
        // Combine both ownVotes and votes
        let allVotes = pollDetails.ownVotes + pollDetails.votes

        // Filter votes belonging to this option
        return allVotes.filter { $0.optionId == option.id }
    }

    public func voter(at index: Int) -> PollVote? {
        let allVoters = voters()
        guard index < allVoters.count else { return nil }
        return allVoters[index]
    }
}
