//
//  ChatRemoteNotificationHandler.swift
//  SceytChatUIKit
//
//  Created by Claude Code on 23.01.26
//  Copyright © 2026 Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat
import UserNotifications

/// Represents the content of a message notification after parsing.
public class MessageNotificationContent {
    public let pushData: PushNotificationData
    public let content: UNNotificationContent

    init(pushData: PushNotificationData, content: UNNotificationContent) {
        self.pushData = pushData
        self.content = content
    }
}

/// Represents unknown notification content that couldn't be parsed.
public class UnknownNotificationContent {
    public let content: UNNotificationContent

    public init(content: UNNotificationContent) {
        self.content = content
    }
}

/// The result of parsing a push notification.
public enum ChatPushNotificationContent {
    case message(MessageNotificationContent)
    case unknown(UnknownNotificationContent)
}

/// Errors that can occur during push notification parsing.
public enum ChatPushNotificationError: Error {
    case invalidUserInfo(String)
    case parsingFailed(Error)
}

/// Handles remote push notifications for chat messages.
/// Used by notification service extensions to parse, store messages, and mark them as received.
open class ChatRemoteNotificationHandler: NSObject {

    // MARK: - Properties

    public let chatClient: ChatClient
    public let content: UNNotificationContent
    private var connectionDelegateId: String?
    private var onConnectionCompletion: ((Error?) -> Void)?

    /// Token provider closure called when connection is needed
    /// - Parameter completion: Called with the token string or nil if unavailable
    public var tokenProvider: ((@escaping (String?) -> Void) -> Void)?

    // MARK: - Initialization

    /// Initializes the notification handler
    /// - Parameters:
    ///   - chatClient: The chat client instance to use for connection and operations
    ///   - content: The notification content to handle
    public init(
        chatClient: ChatClient,
        content: UNNotificationContent
    ) {
        self.chatClient = chatClient
        self.content = content
        super.init()
    }

    deinit {
        cleanupConnectionDelegate()
    }

    // MARK: - Public Methods

    /// Handles the notification by parsing, storing, and optionally marking as received
    /// - Parameters:
    ///   - shouldMarkAsReceived: Whether to mark the message as received after storing
    ///   - completion: Called with the parsed notification content or unknown if parsing failed
    /// - Returns: True if the notification was handled (message notification), false otherwise
    @discardableResult
    open func handleNotification(
        shouldMarkAsReceived: Bool = true,
        completion: @escaping (ChatPushNotificationContent) -> Void
    ) -> Bool {
        logger.verbose("[ChatRemoteNotificationHandler] handleNotification started")

        // Parse the notification content
        guard let pushData = parsePushData() else {
            logger.verbose("[ChatRemoteNotificationHandler] Failed to parse push data, returning unknown")
            completion(.unknown(UnknownNotificationContent(content: content)))
            return false
        }

        logger.verbose("[ChatRemoteNotificationHandler] Successfully parsed push data for message: \(pushData.message?.id ?? "nil")")

        // Store the message
        storeMessage(pushData: pushData) { [weak self] error in
            guard let self = self else {
                return
            }

            if let error = error {
                logger.errorIfNotNil(error, "[ChatRemoteNotificationHandler] Failed to store message")
                completion(.message(MessageNotificationContent(pushData: pushData, content: self.content)))
                return
            }

            logger.verbose("[ChatRemoteNotificationHandler] Message stored successfully")

            // Mark as received if requested
            guard shouldMarkAsReceived else {
                logger.verbose("[ChatRemoteNotificationHandler] Skipping mark as received (not requested)")
                completion(.message(MessageNotificationContent(pushData: pushData, content: self.content)))
                return
            }

            self.sendMarkMessageAsReceived(pushData: pushData, completion: completion)
        }

        return true
    }
    
    open func sendMarkMessageAsReceived(pushData: PushNotificationData, completion: @escaping (ChatPushNotificationContent) -> Void) {
        // Check if already connected
        if self.chatClient.connectionState == .connected {
            logger.verbose("[ChatRemoteNotificationHandler] Chat already connected, marking message")
            self.markMessageAsReceived(pushData: pushData) { _ in
                completion(.message(MessageNotificationContent(pushData: pushData, content: self.content)))
            }
        } else {
            logger.verbose("[ChatRemoteNotificationHandler] Chat not connected, will mark after connection")

            // Get token and connect
            self.tokenProvider? { token in
                guard let token = token else {
                    logger.verbose("[ChatRemoteNotificationHandler] Token not available, skipping connection")
                    completion(.message(MessageNotificationContent(pushData: pushData, content: self.content)))
                    return
                }

                self.waitForConnectionAndMarkMessage(token: token, pushData: pushData) { _ in
                    completion(.message(MessageNotificationContent(pushData: pushData, content: self.content)))
                }
            }
        }
    }

    // MARK: - Private Methods

    private func parsePushData() -> PushNotificationData? {
        let parser = Components.pushNotificationParser.init()
        return parser.parse(userInfo: content.userInfo)
    }

    /// Stores the message to the database
    /// Override this method in subclasses to provide custom storage implementation
    /// - Parameters:
    ///   - pushData: The parsed push notification data
    ///   - completion: Called when storage is complete, with optional error
    open func storeMessage(pushData: PushNotificationData, completion: @escaping (Error?) -> Void) {
        logger.verbose("[ChatRemoteNotificationHandler] Storing message to database")

        // Subclasses should override this method to provide custom storage implementation
        // The default implementation logs a warning
        logger.verbose("[ChatRemoteNotificationHandler] storeMessage not implemented - override in subclass")
        completion(nil)
    }

    /// Marks the message as received
    /// Override this method in subclasses to provide custom marking logic
    /// - Parameters:
    ///   - pushData: The parsed push notification data
    ///   - completion: Called when marking is complete, with optional error
    open func markMessageAsReceived(pushData: PushNotificationData, completion: @escaping (Error?) -> Void) {
        logger.verbose("[ChatRemoteNotificationHandler] Marking message as received")

        guard let message = pushData.message,
              let channel = pushData.channel,
              let messageId = MessageId(message.id),
              let channelId = ChannelId(channel.id) else {
            logger.verbose("[ChatRemoteNotificationHandler] Missing message or channel data, skipping mark as received")
            completion(nil)
            return
        }

        let provider = Components.channelMessageMarkerProvider.init(channelId: channelId)
        provider.mark(ids: [messageId], markerName: "received") { error in
            if let error = error {
                logger.errorIfNotNil(error, "[ChatRemoteNotificationHandler] Mark as received error")
            } else {
                logger.verbose("[ChatRemoteNotificationHandler] Message marked as received: \(messageId)")
            }
            completion(error)
        }
    }

    private func waitForConnectionAndMarkMessage(token: String, pushData: PushNotificationData, completion: @escaping (Error?) -> Void) {
        let delegateId = UUID().uuidString
        self.connectionDelegateId = delegateId
        self.onConnectionCompletion = completion

        logger.verbose("[ChatRemoteNotificationHandler] Waiting for connection with delegate id: \(delegateId)")

        // Add connection delegate
        chatClient.add(delegate: self, identifier: delegateId)
        chatClient.connect(token: token)

        // Store the pushData for later use
        objc_setAssociatedObject(
            self,
            &AssociatedKeys.pushData,
            pushData,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    private func cleanupConnectionDelegate() {
        if let delegateId = connectionDelegateId {
            chatClient.removeDelegate(identifier: delegateId)
            connectionDelegateId = nil
        }
        onConnectionCompletion = nil
        objc_setAssociatedObject(self, &AssociatedKeys.pushData, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - ChatClientDelegate

extension ChatRemoteNotificationHandler: ChatClientDelegate {

    public func chatClient(_ chatClient: ChatClient, didChange state: ConnectionState, error: SceytError?) {
        logger.verbose("[ChatRemoteNotificationHandler] Connection state changed to: \(state)")

        guard let pushData = objc_getAssociatedObject(self, &AssociatedKeys.pushData) as? PushNotificationData,
              let completion = onConnectionCompletion else {
            return
        }

        switch state {
        case .connected:
            // Connection successful, mark message as received
            logger.verbose("[ChatRemoteNotificationHandler] Connected successfully, marking message")
            cleanupConnectionDelegate()

            markMessageAsReceived(pushData: pushData) { error in
                completion(error)
            }

        case .disconnected, .failed:
            // Connection failed, cleanup and complete without error
            // (message is already stored, marking as received is optional)
            logger.verbose("[ChatRemoteNotificationHandler] Connection failed/disconnected, skipping mark as received")
            cleanupConnectionDelegate()
            completion(nil)

        default:
            // Still connecting, wait...
            break
        }
    }
}

// MARK: - Associated Keys

private struct AssociatedKeys {
    static var pushData = "ChatRemoteNotificationHandler.pushData"
}
