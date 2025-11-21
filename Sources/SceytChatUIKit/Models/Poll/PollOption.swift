//
//  PollOption.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 03.11.25.
//

public struct PollOption {
    public let id: String
    public let text: String
}

extension PollOption {
    init(dto: PollOptionDTO) {
        self.id = dto.id
        self.text = dto.name ?? ""
    }
}
