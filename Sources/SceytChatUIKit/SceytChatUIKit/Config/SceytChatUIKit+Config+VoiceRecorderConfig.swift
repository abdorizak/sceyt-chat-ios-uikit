//
//  File.swift
//  SceytChatUIKit
//
//  Created by Sargis on 10/2/25.
//

import Foundation

public enum VoiceRecorderDuration {
    case unlimited
    case maxDuration(durationInMilliseconds: Int64)
}

extension SceytChatUIKit.Config {
    public struct VoiceRecorderConfig {
        public var maxDuration: VoiceRecorderDuration = .maxDuration(durationInMilliseconds: 5 * 60 * 1000) // 5 minutes
        public var bitrate: Int = 32000
        public var samplingRate: Int = 16000

        public init(
            maxDuration: VoiceRecorderDuration = .maxDuration(durationInMilliseconds: 5 * 60 * 1000),
            bitrate: Int = 32000,
            samplingRate: Int = 16000
        ) {
            self.maxDuration = maxDuration
            self.bitrate = bitrate
            self.samplingRate = samplingRate
        }
    }
}
