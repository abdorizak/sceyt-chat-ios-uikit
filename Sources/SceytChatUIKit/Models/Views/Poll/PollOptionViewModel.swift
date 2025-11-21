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
    var voteCount: Int
    var isSelected: Bool
    var progress: Float
    let isAnonymous: Bool
    let isIncoming: Bool
    var isClosed: Bool
    var voters: [ChatUser]

    init(
        id: String,
        text: String,
        voteCount: Int,
        progress: Float,
        selected: Bool,
        isAnonymous: Bool,
        isIncoming: Bool,
        isClosed: Bool,
        voters: [ChatUser]
    ) {
        self.id = id
        self.text = text
        self.voteCount = voteCount
        self.isSelected = selected
        self.progress = progress
        self.voters = voters
        self.isIncoming = isIncoming
        self.isAnonymous = isAnonymous
        self.isClosed = isClosed
    }
}
