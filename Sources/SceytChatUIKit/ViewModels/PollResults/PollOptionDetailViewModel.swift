//
//  PollOptionDetailViewModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import Combine

open class PollOptionDetailViewModel: NSObject {

    @Published public var option: any PollOptionResultProviding
    @Published public var questionText: String
    @Published public var totalVotes: Int
    @Published public var isLoading = false
    @Published public var error: Error?

    public required init(
        option: any PollOptionResultProviding,
        questionText: String,
        totalVotes: Int
    ) {
        self.option = option
        self.questionText = questionText
        self.totalVotes = totalVotes
        super.init()
    }

    // MARK: - Computed Properties

    public var numberOfVoters: Int {
        option.voters.count
    }

    public func voter(at index: Int) -> (any VoterProviding)? {
        guard index < option.voters.count else { return nil }
        return option.voters[index]
    }
}
