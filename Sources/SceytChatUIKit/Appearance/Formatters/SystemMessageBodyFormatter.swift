//
//  SystemMessageBodyFormatter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat

/// A protocol for formatting system message bodies.
public protocol SystemMessageBodyFormatting: MessageFormatting {
    /// Formats a system message into a string.
    ///
    /// - Parameter message: The `ChatMessage` instance to format.
    /// - Returns: A `String` representing the formatted system message.
    func format(_ message: ChatMessage) -> String
}

/// Default implementation for formatting system messages.
open class SystemMessageBodyFormatter: SystemMessageBodyFormatting {

    /// Initialize a new system message formatter
    public init() {}

    /// Formats a system message based on its body content.
    ///
    /// - Parameter message: The system message to format
    /// - Returns: A formatted string describing the system message
    open func format(_ message: ChatMessage) -> String {
        // System messages use the message body to identify the type
        // The message metadata may contain additional information (e.g., member IDs)
        let body = message.body

        // Helper function to get display name for a user ID
        func displayName(userId: UserId) -> String? {
            if userId == SceytChatUIKit.shared.currentUserId {
                return L10n.User.current
            }
            return SceytChatUIKit.shared.formatters.userNameFormatter.format(.init(id: userId))
        }

        // Get the owner's display name
        var owner: String {
            message.user.id == SceytChatUIKit.shared.currentUserId ? L10n.User.current : (displayName(userId: message.user.id) ?? message.user.displayName)
        }

        // Extract member IDs from metadata if available
        var members: String {
            if let metadata = message.metadata,
               let data = metadata.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let memberIds = json["m"] as? [UserId] {
                return memberIds.compactMap { displayName(userId: $0) ?? "+\($0)" }.joined(separator: ", ")
            }
            return ""
        }


        // Extract disappearing message time from metadata if available
        var disappearingTime: String {
            guard let metadata = message.metadata,
                  let disappearingMetadata = SystemMessageMetadata.DisappearingMessage.from(jsonString: metadata),
                  let timeInterval = disappearingMetadata.toTimeInterval() else {
                return ""
            }

            if timeInterval == 0 {
                return L10n.System.Message.disableDisappearingMessages(owner)
            } else {
                let formattedTime = SceytChatUIKit.shared.formatters.timeIntervalFormatter.format(timeInterval)
                return L10n.System.Message.setDisappearingMessageTime(owner, formattedTime)
            }
        }

        // Format the system message based on its type
        switch body {
        case "CG": // createGroup
            let displayName = displayName(userId: message.user.id) ?? message.user.displayName
            return L10n.System.Message.createGroup(displayName)
        case "CC": // createChannel
            let displayName = displayName(userId: message.user.id) ?? message.user.displayName
            return L10n.System.Message.createChannel(displayName)
        case "AM": // addGroupMember
            return L10n.System.Message.addGroupMember(owner, members)
        case "RM": // removeGroupMember
            return L10n.System.Message.removeGroupMember(owner, members)
        case "LG": // leaveGroup
            return L10n.System.Message.leaveGroup(owner)
        case "JL": // joinByInviteLink
            return L10n.System.Message.joinByInviteLink(owner)
        case "ADM": // setDisappearingMessageTime
            return disappearingTime
        default:
            // For unknown system message types, return the body as-is
            return body
        }
    }
}
