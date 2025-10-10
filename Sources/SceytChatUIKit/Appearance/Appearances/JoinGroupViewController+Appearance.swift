//
//  JoinGroupViewController+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension JoinGroupViewController: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSecondary,
        avatarBorderWidth: 0,
        avatarBorderColor: .clear,
        channelNameLabelAppearance: LabelAppearance(
            foregroundColor: .primaryText,
            font: .systemFont(ofSize: 24, weight: .semibold),
            backgroundColor: .clear
        ),
        channelDescriptionLabelAppearance: LabelAppearance(
            foregroundColor: .secondaryLabel,
            font: .systemFont(ofSize: 14, weight: .regular),
            backgroundColor: .clear
        ),
        joinButtonAppearance: .init(
            labelAppearance: .init(
                foregroundColor: .onPrimary,
                font: Fonts.semiBold.withSize(16)
            ),
            tintColor: .onPrimary,
            backgroundColor: .accent,
            highlightedBackgroundColor: .accent.withAlphaComponent(0.8),
            cornerRadius: 8,
            cornerCurve: .continuous
        ),
        closeButtonTintColor: .closeButtonTint,
        closeButtonBackgroundColor: .closeButtonBackground,
        avatarAppearance: AvatarAppearance.standard,
        avatarRenderer: SceytChatUIKit.shared.avatarRenderers.channelAvatarRenderer,
        joinButtonTitle: L10n.JoinGroup.Button.join,
        joiningButtonTitle: L10n.JoinGroup.Button.joining
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, CGFloat>
        public var avatarBorderWidth: CGFloat

        @Trackable<Appearance, UIColor?>
        public var avatarBorderColor: UIColor?

        @Trackable<Appearance, LabelAppearance>
        public var channelNameLabelAppearance: LabelAppearance

        @Trackable<Appearance, LabelAppearance>
        public var channelDescriptionLabelAppearance: LabelAppearance

        @Trackable<Appearance, ButtonAppearance>
        public var joinButtonAppearance: ButtonAppearance

        @Trackable<Appearance, UIColor>
        public var closeButtonTintColor: UIColor

        @Trackable<Appearance, UIColor>
        public var closeButtonBackgroundColor: UIColor

        @Trackable<Appearance, AvatarAppearance>
        public var avatarAppearance: AvatarAppearance

        @Trackable<Appearance, any ChannelAvatarRendering>
        public var avatarRenderer: any ChannelAvatarRendering

        @Trackable<Appearance, String>
        public var joinButtonTitle: String

        @Trackable<Appearance, String>
        public var joiningButtonTitle: String

        public init(
            backgroundColor: UIColor,
            avatarBorderWidth: CGFloat,
            avatarBorderColor: UIColor?,
            channelNameLabelAppearance: LabelAppearance,
            channelDescriptionLabelAppearance: LabelAppearance,
            joinButtonAppearance: ButtonAppearance,
            closeButtonTintColor: UIColor,
            closeButtonBackgroundColor: UIColor,
            avatarAppearance: AvatarAppearance,
            avatarRenderer: any ChannelAvatarRendering,
            joinButtonTitle: String,
            joiningButtonTitle: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._avatarBorderWidth = Trackable(value: avatarBorderWidth)
            self._avatarBorderColor = Trackable(value: avatarBorderColor)
            self._channelNameLabelAppearance = Trackable(value: channelNameLabelAppearance)
            self._channelDescriptionLabelAppearance = Trackable(value: channelDescriptionLabelAppearance)
            self._joinButtonAppearance = Trackable(value: joinButtonAppearance)
            self._closeButtonTintColor = Trackable(value: closeButtonTintColor)
            self._closeButtonBackgroundColor = Trackable(value: closeButtonBackgroundColor)
            self._avatarAppearance = Trackable(value: avatarAppearance)
            self._avatarRenderer = Trackable(value: avatarRenderer)
            self._joinButtonTitle = Trackable(value: joinButtonTitle)
            self._joiningButtonTitle = Trackable(value: joiningButtonTitle)
        }

        public init(
            reference: JoinGroupViewController.Appearance,
            backgroundColor: UIColor? = nil,
            avatarBorderWidth: CGFloat? = nil,
            avatarBorderColor: UIColor? = nil,
            channelNameLabelAppearance: LabelAppearance? = nil,
            channelDescriptionLabelAppearance: LabelAppearance? = nil,
            joinButtonAppearance: ButtonAppearance? = nil,
            closeButtonTintColor: UIColor? = nil,
            closeButtonBackgroundColor: UIColor? = nil,
            avatarAppearance: AvatarAppearance? = nil,
            avatarRenderer: (any ChannelAvatarRendering)? = nil,
            joinButtonTitle: String? = nil,
            joiningButtonTitle: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._avatarBorderWidth = Trackable(reference: reference, referencePath: \.avatarBorderWidth)
            self._avatarBorderColor = Trackable(reference: reference, referencePath: \.avatarBorderColor)
            self._channelNameLabelAppearance = Trackable(reference: reference, referencePath: \.channelNameLabelAppearance)
            self._channelDescriptionLabelAppearance = Trackable(reference: reference, referencePath: \.channelDescriptionLabelAppearance)
            self._joinButtonAppearance = Trackable(reference: reference, referencePath: \.joinButtonAppearance)
            self._closeButtonTintColor = Trackable(reference: reference, referencePath: \.closeButtonTintColor)
            self._closeButtonBackgroundColor = Trackable(reference: reference, referencePath: \.closeButtonBackgroundColor)
            self._avatarAppearance = Trackable(reference: reference, referencePath: \.avatarAppearance)
            self._avatarRenderer = Trackable(reference: reference, referencePath: \.avatarRenderer)
            self._joinButtonTitle = Trackable(reference: reference, referencePath: \.joinButtonTitle)
            self._joiningButtonTitle = Trackable(reference: reference, referencePath: \.joiningButtonTitle)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let avatarBorderWidth {
                self.avatarBorderWidth = avatarBorderWidth
            }
            if let avatarBorderColor {
                self.avatarBorderColor = avatarBorderColor
            }
            if let channelNameLabelAppearance {
                self.channelNameLabelAppearance = channelNameLabelAppearance
            }
            if let channelDescriptionLabelAppearance {
                self.channelDescriptionLabelAppearance = channelDescriptionLabelAppearance
            }
            if let joinButtonAppearance {
                self.joinButtonAppearance = joinButtonAppearance
            }
            if let closeButtonTintColor {
                self.closeButtonTintColor = closeButtonTintColor
            }
            if let closeButtonBackgroundColor {
                self.closeButtonBackgroundColor = closeButtonBackgroundColor
            }
            if let avatarAppearance {
                self.avatarAppearance = avatarAppearance
            }
            if let avatarRenderer {
                self.avatarRenderer = avatarRenderer
            }
            if let joinButtonTitle {
                self.joinButtonTitle = joinButtonTitle
            }
            if let joiningButtonTitle {
                self.joiningButtonTitle = joiningButtonTitle
            }
        }
    }
}
