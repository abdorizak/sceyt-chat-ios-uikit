//
//  ReplyUserNameFormatter.swift
//  SceytChatUIKit
//
//  Created by Tigran Vilasyan on 25.12.25.
//

open class ReplyUserNameFormatter: UserFormatting {
    
    public init() {}
    
    open func format(_ user: ChatUser) -> String {
        switch user.state {
        case .deleted:
            return L10n.User.deleted
        case .inactive:
            return L10n.User.inactive
        default:
            break
        }
        
        let displayName = [user.firstName, user.lastName]
            .compactMap {
                let name = $0?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return name.isEmpty ? nil : name
            }
            .joined(separator: " ")
        
        if displayName.isEmpty {
            return user.id
        } else {
            return displayName
        }
    }
}
