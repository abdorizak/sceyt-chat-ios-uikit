//
//  PushNotificationData.swift
//  SceytChatUIKit
//
//  Created by Claude Code on 23.01.26
//  Copyright © 2026 Sceyt LLC. All rights reserved.
//

import Foundation
import SceytChat

/// Represents push notification data parsed from userInfo
open class PushNotificationData {

    public var message: Message?
    public var channel: Channel?
    public var user: User?
    public var reaction: Reaction?
    public var userInfo: [AnyHashable: Any]?

    public init() {}

    public init(
        message: Message? = nil,
        channel: Channel? = nil,
        user: User? = nil,
        reaction: Reaction? = nil,
        userInfo: [AnyHashable: Any]? = nil
    ) {
        self.message = message
        self.channel = channel
        self.user = user
        self.reaction = reaction
        self.userInfo = userInfo
    }
}

// MARK: - Nested Types

public extension PushNotificationData {

    struct Message: Decodable {
        public let id: String
        public let parentId: String?
        public let body: String
        public let bodyAttributes: [BodyAttribute]?
        public let type: String
        public let metadata: String
        public let createdAt: String
        public let updatedAt: String
        public let state: String
        public let deliveryStatus: String
        public let transient: Bool
        public let attachments: [Attachment]?
        public let forwardingDetails: ForwardingDetails?
        public let mentionedUsers: [User]?

        enum CodingKeys: String, CodingKey {
            case id, body, type, metadata, state, transient, attachments, mentionedUsers
            case parentId = "parent_id"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case deliveryStatus = "delivery_status"
            case forwardingDetails = "forwarding_details"
            case bodyAttributes = "body_attributes"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            parentId = try? values.decode(String.self, forKey: .parentId)
            body = try values.decode(String.self, forKey: .body)
            bodyAttributes = try? values.decodeIfPresent([BodyAttribute].self, forKey: .bodyAttributes)
            type = try values.decode(String.self, forKey: .type)
            metadata = try values.decode(String.self, forKey: .metadata)
            createdAt = try values.decode(String.self, forKey: .createdAt)
            updatedAt = try values.decode(String.self, forKey: .updatedAt)
            state = try values.decode(String.self, forKey: .state)
            deliveryStatus = try values.decode(String.self, forKey: .deliveryStatus)
            transient = try values.decode(Bool.self, forKey: .transient)
            attachments = try values.decodeIfPresent([Attachment].self, forKey: .attachments)
            forwardingDetails = try? values.decodeIfPresent(ForwardingDetails.self, forKey: .forwardingDetails)
            mentionedUsers = try? values.decodeIfPresent([User].self, forKey: .mentionedUsers)
        }

        public init(
            id: String,
            parentId: String? = nil,
            body: String,
            bodyAttributes: [BodyAttribute]? = nil,
            type: String,
            metadata: String,
            createdAt: String,
            updatedAt: String,
            state: String,
            deliveryStatus: String,
            transient: Bool,
            attachments: [Attachment]? = nil,
            forwardingDetails: ForwardingDetails? = nil,
            mentionedUsers: [User]? = nil
        ) {
            self.id = id
            self.parentId = parentId
            self.body = body
            self.bodyAttributes = bodyAttributes
            self.type = type
            self.metadata = metadata
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.state = state
            self.deliveryStatus = deliveryStatus
            self.transient = transient
            self.attachments = attachments
            self.forwardingDetails = forwardingDetails
            self.mentionedUsers = mentionedUsers
        }
    }

    struct Channel: Decodable {
        public let id: String
        public let type: String
        public let uri: String
        public let subject: String
        public let metadata: String
        public let membersCount: Int64

        enum CodingKeys: String, CodingKey {
            case id, type, uri, subject, metadata
            case membersCount = "members_count"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            type = try values.decode(String.self, forKey: .type)
            uri = try values.decode(String.self, forKey: .uri)
            subject = try values.decode(String.self, forKey: .subject)
            metadata = try values.decode(String.self, forKey: .metadata)
            membersCount = try values.decode(Int64.self, forKey: .membersCount)
        }

        public init(
            id: String,
            type: String,
            uri: String,
            subject: String,
            metadata: String,
            membersCount: Int64
        ) {
            self.id = id
            self.type = type
            self.uri = uri
            self.subject = subject
            self.metadata = metadata
            self.membersCount = membersCount
        }
    }

    struct User: Decodable {
        public let id: String
        public let firstName: String
        public let lastName: String
        public let metadata: [String: String]
        public let presenceStatus: String

        public var displayName: String {
            if firstName.isEmpty, lastName.isEmpty {
                return ""
            }
            return [firstName, lastName].joined(separator: " ")
        }

        enum CodingKeys: String, CodingKey {
            case id, metadata
            case firstName = "first_name"
            case lastName = "last_name"
            case presenceStatus = "presence_status"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            firstName = try values.decode(String.self, forKey: .firstName)
            lastName = try values.decode(String.self, forKey: .lastName)
            presenceStatus = try values.decode(String.self, forKey: .presenceStatus)

            if let metadataString = try? values.decode(String.self, forKey: .metadata),
               let data = metadataString.data(using: .utf8),
               let metadataDict = try? JSONDecoder().decode([String: String].self, from: data) {
                metadata = metadataDict
            } else {
                metadata = [:]
            }
        }

        public init(
            id: String,
            firstName: String = "",
            lastName: String = "",
            metadata: [String: String] = [:],
            presenceStatus: String = ""
        ) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.metadata = metadata
            self.presenceStatus = presenceStatus
        }
    }

    struct Reaction: Decodable {
        public let id: String?
        public let key: String
        public let score: Int
        public let reason: String
        public let createdAt: Double

        enum CodingKeys: String, CodingKey {
            case id, key, score, reason
            case createdAt = "created_at"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try? values.decode(String.self, forKey: .id)
            key = try values.decode(String.self, forKey: .key)
            score = try values.decode(Int.self, forKey: .score)
            reason = try values.decode(String.self, forKey: .reason)
            createdAt = try values.decode(Double.self, forKey: .createdAt)
        }

        public init(
            id: String? = nil,
            key: String,
            score: Int,
            reason: String,
            createdAt: Double
        ) {
            self.id = id
            self.key = key
            self.score = score
            self.reason = reason
            self.createdAt = createdAt
        }
    }

    struct BodyAttribute: Decodable {
        public let offset: Int
        public let length: Int
        public let type: String
        public let metadata: String?

        public init(offset: Int, length: Int, type: String, metadata: String? = nil) {
            self.offset = offset
            self.length = length
            self.type = type
            self.metadata = metadata
        }
    }

    struct Attachment: Codable {
        public let data: String
        public let type: String
        public let name: String?
        public let metadata: String?
        public let size: Int?

        public init(data: String, type: String, name: String? = nil, metadata: String? = nil, size: Int? = nil) {
            self.data = data
            self.type = type
            self.name = name
            self.metadata = metadata
            self.size = size
        }
    }

    struct ForwardingDetails: Codable {
        public let channelId: String
        public let messageId: String
        public let hops: Int
        public let userId: String

        enum CodingKeys: String, CodingKey {
            case channelId = "channel_id"
            case messageId = "message_id"
            case userId = "user_id"
            case hops
        }

        public init(channelId: String, messageId: String, hops: Int, userId: String) {
            self.channelId = channelId
            self.messageId = messageId
            self.hops = hops
            self.userId = userId
        }
    }
}
