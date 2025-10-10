//
//  SceytChatUIKit+Config+ChannelInviteDeepLinkConfig.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation

extension SceytChatUIKit.Config {
    public struct ChannelInviteDeepLinkConfig {
        public let scheme: String
        public let host: String
        public let pathPrefix: String
        
        public init(
            scheme: String,
            host: String,
            pathPrefix: String
        ) {
            self.scheme = scheme
            self.host = host
            self.pathPrefix = pathPrefix
        }
        
        /// Constructs the full invite link URL for a given channel URI
        /// - Parameter channelURI: The channel URI to append to the path
        /// - Returns: The complete invite link URL string
        public func constructInviteLink(for channelURI: String) -> String {
            return "\(scheme)://\(host)\(pathPrefix)\(channelURI)"
        }
    }
}