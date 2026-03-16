//
//  PushNotificationParser.swift
//  SceytChatUIKit
//
//  Created by Claude Code on 23.01.26
//  Copyright © 2026 Sceyt LLC. All rights reserved.
//

import Foundation
import UserNotifications

/// Protocol for parsing push notification content
public protocol PushNotificationParsing {
    /// Parses userInfo dictionary into structured push notification data
    /// - Parameter userInfo: The userInfo dictionary from UNNotificationContent
    /// - Returns: Parsed push notification data, or nil if parsing failed
    func parse(userInfo: [AnyHashable: Any]) -> PushNotificationData?
}

/// Default implementation of push notification parsing
/// Parses notification data from the standard Sceyt push notification format
open class DefaultPushNotificationParser: PushNotificationParsing {

    required public init() {}

    /// Parses userInfo into PushNotificationData
    /// Expected format: userInfo["data"] contains JSON strings for message, channel, user, reaction
    open func parse(userInfo: [AnyHashable: Any]) -> PushNotificationData? {
        logger.verbose("[PushNotificationParser] Parsing userInfo")

        let pushData = PushNotificationData()
        pushData.userInfo = userInfo

        guard let data = userInfo["data"] as? [AnyHashable: Any] else {
            logger.verbose("[PushNotificationParser] No 'data' key found in userInfo")
            return nil
        }

        // Parse message
        if let string = data["message"] as? String,
           let jsonData = string.data(using: .utf8) {
            do {
                pushData.message = try JSONDecoder().decode(PushNotificationData.Message.self, from: jsonData)
                logger.verbose("[PushNotificationParser] Successfully parsed message")
            } catch {
                logger.errorIfNotNil(error, "[PushNotificationParser] Failed to parse message")
            }
        }

        // Parse channel
        if let string = data["channel"] as? String,
           let jsonData = string.data(using: .utf8) {
            do {
                pushData.channel = try JSONDecoder().decode(PushNotificationData.Channel.self, from: jsonData)
                logger.verbose("[PushNotificationParser] Successfully parsed channel")
            } catch {
                logger.errorIfNotNil(error, "[PushNotificationParser] Failed to parse channel")
            }
        }

        // Parse user
        if let string = data["user"] as? String,
           let jsonData = string.data(using: .utf8) {
            do {
                pushData.user = try JSONDecoder().decode(PushNotificationData.User.self, from: jsonData)
                logger.verbose("[PushNotificationParser] Successfully parsed user")
            } catch {
                logger.errorIfNotNil(error, "[PushNotificationParser] Failed to parse user")
            }
        }

        // Parse reaction
        if let string = data["reaction"] as? String,
           let jsonData = string.data(using: .utf8) {
            do {
                pushData.reaction = try JSONDecoder().decode(PushNotificationData.Reaction.self, from: jsonData)
                logger.verbose("[PushNotificationParser] Successfully parsed reaction")
            } catch {
                logger.errorIfNotNil(error, "[PushNotificationParser] Failed to parse reaction")
            }
        }

        return pushData
    }
}
