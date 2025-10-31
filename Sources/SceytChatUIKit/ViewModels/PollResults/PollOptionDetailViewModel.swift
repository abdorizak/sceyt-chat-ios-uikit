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

    open private(set) var votesQuery: PollVotesListQuery!
    private var allVoters: [PollVote] = []

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

        // Initialize query for fetching voters
        createVotesQuery()

        // Initialize with existing voters
        allVoters = voters()
    }

    private func createVotesQuery() {
        votesQuery = PollVotesListQuery
            .Builder(pollId: pollDetails.id)
            .optionId(option.id)
            .limit(SceytChatUIKit.shared.config.queryLimits.pollVotersListQueryLimit)
            .build()
    }

    // MARK: - Computed Properties

    public var numberOfVoters: Int {
        allVoters.count
    }

    public func voters() -> [PollVote] {
        // Combine both ownVotes and votes
        let allVotes = pollDetails.ownVotes

        // Filter votes belonging to this option
        return allVotes.filter { $0.optionId == option.id }
    }

    public func voter(at index: Int) -> PollVote? {
        guard index < allVoters.count else { return nil }
        return allVoters[index]
    }

    // MARK: - Public Methods

    open func loadNext() {
        guard votesQuery.hasNext, !votesQuery.loading, !isLoading else { return }

        isLoading = true

        votesQuery.loadNext { [weak self] _, votes, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.error = error
                    return
                }

                if let votes = votes {
                    let pollVotes = votes.map { vote in
                        PollVote(
                            pollId: self.pollDetails.id,
                            optionId: self.option.id,
                            userId: vote.user.id ?? "",
                            createdAt: Int64(vote.createdAt.timeIntervalSince1970),
                            user: ChatUser(user: vote.user)
                        )
                    }
                    
                    // Append new voters to the existing list
                    pollVotes.forEach {
                        self.allVoters.append($0)
                    }
                }
            }
        }
    }

    public var hasMore: Bool {
        votesQuery.hasNext
    }
}
