//
//  ChannelInviteLinkViewController+ActionCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension ChannelInviteLinkViewController.ActionCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSections,
        titleLabelAppearance: .init(
            foregroundColor: .primaryText,
            font: Fonts.regular.withSize(16)
        ),
        separatorColor: .clear,
        switchTintColor: .accent
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, LabelAppearance>
        public var titleLabelAppearance: LabelAppearance

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        @Trackable<Appearance, UIColor>
        public var switchTintColor: UIColor

        public init(
            backgroundColor: UIColor,
            titleLabelAppearance: LabelAppearance,
            separatorColor: UIColor,
            switchTintColor: UIColor
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._titleLabelAppearance = Trackable(value: titleLabelAppearance)
            self._separatorColor = Trackable(value: separatorColor)
            self._switchTintColor = Trackable(value: switchTintColor)
        }

        public init(
            reference: ChannelInviteLinkViewController.ActionCell.Appearance,
            backgroundColor: UIColor? = nil,
            titleLabelAppearance: LabelAppearance? = nil,
            separatorColor: UIColor? = nil,
            switchTintColor: UIColor? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._titleLabelAppearance = Trackable(reference: reference, referencePath: \.titleLabelAppearance)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._switchTintColor = Trackable(reference: reference, referencePath: \.switchTintColor)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let titleLabelAppearance {
                self.titleLabelAppearance = titleLabelAppearance
            }
            if let separatorColor {
                self.separatorColor = separatorColor
            }
            if let switchTintColor {
                self.switchTintColor = switchTintColor
            }
        }
    }
}
