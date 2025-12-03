//
//  MessageTypeSupportProvider.swift
//  SceytChatUIKit
//
//  Created by SceytChatUIKit on 10.11.24.
//

import Foundation

/// Default implementation of `MessageTypeSupportProviding` that determines
/// whether a message type is supported by the application.
///
/// By default, the following message types are supported:
/// - "text": Standard text messages
/// - "media": Media messages (images/videos)
/// - "file": File attachments
/// - "link": Link messages
/// - "system": System messages
/// - "poll": Poll messages
///
/// Any other message type is considered unsupported.
///
/// You can customize which message types are supported by implementing
/// your own `MessageTypeSupportProviding` and setting it in `Appearance.messageTypeSupportProvider`.
public struct MessageTypeSupportProvider: MessageTypeSupportProviding {
    
    /// The set of supported message types
    public var supportedTypes: Set<String>
    
    /// Initializes a new provider with default supported types
    public init() {
        self.supportedTypes = ["text", "media", "file", "link", "system", "poll"]
    }
    
    /// Initializes a new provider with custom supported types
    /// - Parameter supportedTypes: A set of message type strings that should be considered supported
    public init(supportedTypes: Set<String>) {
        self.supportedTypes = supportedTypes
    }
    
    /// Determines whether the specified message type is supported
    /// - Parameter message: The message to check
    /// - Returns: `true` if the message type is in the supported types set, `false` otherwise
    public func provideVisual(for message: ChatMessage) -> Bool {
        return supportedTypes.contains(message.type)
    }
}

