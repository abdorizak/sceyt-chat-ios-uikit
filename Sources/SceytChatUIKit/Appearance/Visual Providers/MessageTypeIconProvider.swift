//
//  MessageTypeIconProvider.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//

import UIKit

/// A protocol for providing icons for different message types in channel list.
public protocol MessageTypeIconProviding: VisualProviding {
    /// Provides an icon image for the specified message.
    ///
    /// - Parameter message: The message for which to provide the icon.
    /// - Returns: An optional `UIImage` representing the message type icon.
    func provideVisual(for message: ChatMessage) -> UIImage?
}

/// Default implementation of MessageTypeIconProviding for channel list message type icons.
public struct DefaultMessageTypeIconProvider: MessageTypeIconProviding {

    public init() {}

    public func provideVisual(for message: ChatMessage) -> UIImage? {
        // Check for view_once message type
        if message.isViewOnceMessage {
            let viewOnceIcon = UIImage.iconViewOnce
            let targetSize = CGSize(width: 16, height: 16)
            let resizedIcon = resizeImage(viewOnceIcon, to: targetSize)
            return resizedIcon?.withRenderingMode(.alwaysTemplate)
        }

        // Check for poll first
        if message.poll != nil && message.type == "poll" {
            // Resize and recolor poll icon to match attachment icons
            let pollIcon = UIImage.chatActionPoll
            let targetSize = CGSize(width: 13, height: 13)
            let resizedIcon = resizeImage(pollIcon, to: targetSize)
            return resizedIcon?.withRenderingMode(.alwaysTemplate)
        }

        // Check for attachments
        if let attachment = message.attachments?.last {
            switch attachment.type {
            case "file":
                return .attachmentFile
            case "image":
                return .attachmentImage
            case "video":
                return .attachmentVideo
            case "voice":
                return .attachmentVoice
            default:
                return nil
            }
        }

        return nil
    }

    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
