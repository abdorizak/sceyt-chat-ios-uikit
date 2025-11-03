//
//  CreatePollModel+Builder.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat

public extension CreatePollModel {
    /// Creates a SceytChat.PollDetails instance from the CreatePollModel
    /// - Returns: A configured PollDetails instance
    func toPollDetails() -> SceytChat.PollDetails {
        let validOptions = options
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { option in
                SceytChat.PollOption(id: UUID().uuidString, name: option)
            }
        
        
        return SceytChat.PollDetails.init(id: UUID().uuidString,
                                          name: question,
                                          description: "",
                                          options: validOptions,
                                          anonymous: self.isAnonymous,
                                          allowMultipleVotes: self.allowMultipleAnswers,
                                          allowVoteRetract: false)
    }
}

