//
//  VoterDateFormatter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation

open class VoterDateFormatter: DateFormatting {

    public init() {}

    open lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return formatter
    }()

    open func format(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
