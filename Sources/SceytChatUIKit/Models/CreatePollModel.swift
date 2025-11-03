//
//  CreatePollModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation

public struct CreatePollModel {
    public var question: String
    public var options: [String]
    public var allowMultipleAnswers: Bool
    public var isAnonymous: Bool

    public init(
        question: String = "",
        options: [String] = ["", ""],
        allowMultipleAnswers: Bool = true,
        isAnonymous: Bool = false
    ) {
        self.question = question
        self.options = options
        self.allowMultipleAnswers = allowMultipleAnswers
        self.isAnonymous = isAnonymous
    }

    public var isValid: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        options.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 2
    }
}
