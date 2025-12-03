//
//  SystemMessageMetadata.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC. All rights reserved.
//

import Foundation

/// Metadata models for system messages
public enum SystemMessageMetadata {

    /// Metadata for disappearing message system messages (ADM type)
    public struct DisappearingMessage: Codable {
        /// Auto-delete period in milliseconds
        public let autoDeletePeriod: String

        public init(autoDeletePeriod: String) {
            self.autoDeletePeriod = autoDeletePeriod
        }

        /// Creates metadata from a time interval
        /// - Parameter timeInterval: Time interval in seconds
        /// - Returns: DisappearingMessage metadata with period in milliseconds
        public static func from(timeInterval: TimeInterval) -> DisappearingMessage {
            let milliseconds = Int(timeInterval * 1000)
            return DisappearingMessage(autoDeletePeriod: "\(milliseconds)")
        }

        /// Converts to time interval
        /// - Returns: Time interval in seconds, or nil if conversion fails
        public func toTimeInterval() -> TimeInterval? {
            guard let milliseconds = Double(autoDeletePeriod) else { return nil }
            return TimeInterval(milliseconds) / 1000.0
        }

        /// Encodes to JSON string
        /// - Returns: JSON string representation, or nil if encoding fails
        public func toJSONString() -> String? {
            guard let data = try? JSONEncoder().encode(self),
                  let jsonString = String(data: data, encoding: .utf8) else {
                return nil
            }
            return jsonString
        }

        /// Decodes from JSON string
        /// - Parameter jsonString: JSON string to decode
        /// - Returns: DisappearingMessage instance, or nil if decoding fails
        public static func from(jsonString: String) -> DisappearingMessage? {
            guard let data = jsonString.data(using: .utf8),
                  let metadata = try? JSONDecoder().decode(DisappearingMessage.self, from: data) else {
                return nil
            }
            return metadata
        }
    }
}
