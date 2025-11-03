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
    @Published public var event: Event?
    @Published public var isLoading = false
    @Published public var error: Error?

    public let messageID: MessageId

    open private(set) var votesQuery: PollVotesListQuery!
    private var allVoters: [PollVote] = []

    public required init(
        option: PollOption,
        pollDetails: PollDetails,
        messageID: MessageId
    ) {
        self.option = option
        self.pollDetails = pollDetails
        self.messageID = messageID
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
            .messageID(messageID)
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

        votesQuery.loadNext { [weak self] _, voters, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.error = error
                    return
                }

                if let newVoters = voters {
                    for v in newVoters {
                        let pollVote = PollVote(
                            pollId: self.pollDetails.id,
                            optionId: self.option.id,
                            userId: v.user.id ?? "",
                            createdAt: Int64(v.createdAt.timeIntervalSince1970),
                            user: ChatUser(user: v.user)
                        )
                        
                        self.allVoters.append(pollVote)
                    }

                    // Trigger table view reload
                    self.event = .reloadData
                }
            }
        }
    }

    public var hasMore: Bool {
        votesQuery.hasNext
    }
}

public extension PollOptionDetailViewModel {
    enum Event {
        case reloadData
    }
}
