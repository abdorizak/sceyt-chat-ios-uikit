//
//  PollOptionViewModel.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 03.11.25.
//

/// UI model for displaying poll option in the view
public struct PollOptionViewModel {
    let id: String
    let text: String
    let voteCount: Int
    let isSelected: Bool
    let progress: Float
    let isAnonymous: Bool
    let voters: [ChatUser]

    init(
        id: String,
        text: String,
        voteCount: Int,
        progress: Float,
        selected: Bool,
        isAnonymous: Bool,
        voters: [ChatUser]
    ) {
        self.id = id
        self.text = text
        self.voteCount = voteCount
        self.isSelected = selected
        self.progress = progress
        self.voters = voters
        self.isAnonymous = isAnonymous
    }
}
