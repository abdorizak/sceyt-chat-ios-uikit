//
//  ChannelEventView+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sergey Charchoghlyan on 02.07.25.
//

import UIKit

extension ChannelEventView: AppearanceProviding {
    public static var appearance = Appearance(
        labelAppearance: LabelAppearance(
            foregroundColor: .secondaryText,
            font: Fonts.regular.withSize(13)
        ),
        channelEventFormatter: SceytChatUIKit.shared.formatters.channelEventTitleFormatter
    )
    
    public struct Appearance {
        @Trackable<Appearance, LabelAppearance>
        public var labelAppearance: LabelAppearance
        
        @Trackable<Appearance, any ChannelEventTitleFormatting>
        public var channelEventFormatter: any ChannelEventTitleFormatting
        
        // Convenience initializer with optional parameters
        public init(
            labelAppearance: LabelAppearance,
            channelEventFormatter: any ChannelEventTitleFormatting
        ) {
            self._labelAppearance = Trackable(value: labelAppearance)
            self._channelEventFormatter = Trackable(value: channelEventFormatter)
           
        }
        
        public init(
            reference: ChannelEventView.Appearance,
            labelAppearance: LabelAppearance? = nil,
            channelEventFormatter: (any ChannelEventTitleFormatting)? = nil
        ) {
            self._labelAppearance = Trackable(reference: reference, referencePath: \.labelAppearance)
            self._channelEventFormatter = Trackable(reference: reference, referencePath: \.channelEventFormatter)
            
            if let labelAppearance { self.labelAppearance = labelAppearance }
            if let channelEventFormatter { self.channelEventFormatter = channelEventFormatter }
        }
    }
}
