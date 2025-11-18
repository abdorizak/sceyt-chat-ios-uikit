//
//  PollResultsModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation

public protocol PollVoterRepresentable {
    var user: ChatUser? { get }
    var createdAtDate: Date { get }
    var optionId: String { get }
}
