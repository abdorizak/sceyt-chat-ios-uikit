//
//  PollResultsModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation

public struct PollResultsModel {
    public var question: String
    public var options: [PollOptionResult]

    public init(
        question: String = "",
        options: [PollOptionResult] = []
    ) {
        self.question = question
        self.options = options
    }
}

public struct PollOptionResult {
    public var optionText: String
    public var voters: [Voter]
    public var voteCount: Int = 0

    public init(
        optionText: String = "",
        voters: [Voter] = [],
        voteCount: Int = 0
    ) {
        self.optionText = optionText
        self.voters = voters
        self.voteCount = voteCount
    }

    public struct Voter {
        public var member: ChatChannelMember
        public var votedAt: Date

        public init(
            member: ChatChannelMember,
            votedAt: Date
        ) {
            self.member = member
            self.votedAt = votedAt
        }
    }
}
