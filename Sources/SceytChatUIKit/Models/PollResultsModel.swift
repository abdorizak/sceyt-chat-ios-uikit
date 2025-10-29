//
//  PollResultsModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation

public protocol PollResultsProviding {
    var question: String { get }
    var options: [any PollOptionResultProviding] { get }
}

public struct PollResultsModel: PollResultsProviding {
    public var question: String
    public var options: [any PollOptionResultProviding]

    public init(
        question: String = "",
        options: [any PollOptionResultProviding] = []
    ) {
        self.question = question
        self.options = options
    }
}

public protocol VoterProviding {
    var member: ChatChannelMember { get }
    var votedAt: Date { get }
}

public protocol PollOptionResultProviding {
    var optionText: String { get }
    var voters: [any VoterProviding] { get }
    var voteCount: Int { get }
}

public struct PollOptionResult: PollOptionResultProviding {
    public var optionText: String
    public var voters: [any VoterProviding]
    public var voteCount: Int = 0

    public init(
        optionText: String = "",
        voters: [any VoterProviding] = [],
        voteCount: Int = 0
    ) {
        self.optionText = optionText
        self.voters = voters
        self.voteCount = voteCount
    }

    public struct Voter: VoterProviding {
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
