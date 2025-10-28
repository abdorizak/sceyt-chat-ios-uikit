//
//  PollResultsViewController+VoterCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollResultsViewController.VoterCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSections,
        titleLabelAppearance: .init(
            foregroundColor: .primaryText,
            font: Fonts.semiBold.withSize(16)
        ),
        subtitleLabelAppearance: .init(
            foregroundColor: .secondaryText,
            font: Fonts.regular.withSize(16)
        ),
        avatarSize: CGSize(width: 40, height: 40),
        separatorColor: .border,
        avatarRenderer: AnyUserAvatarRendering(SceytChatUIKit.shared.avatarRenderers.userAvatarRenderer),
        avatarAppearance: AvatarAppearance.standard
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, LabelAppearance>
        public var titleLabelAppearance: LabelAppearance

        @Trackable<Appearance, LabelAppearance>
        public var subtitleLabelAppearance: LabelAppearance

        @Trackable<Appearance, CGSize>
        public var avatarSize: CGSize

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        public var avatarRenderer: AnyUserAvatarRendering

        public var avatarAppearance: AvatarAppearance

        public init(
            backgroundColor: UIColor,
            titleLabelAppearance: LabelAppearance,
            subtitleLabelAppearance: LabelAppearance,
            avatarSize: CGSize,
            separatorColor: UIColor,
            avatarRenderer: AnyUserAvatarRendering,
            avatarAppearance: AvatarAppearance
        ) {
            _backgroundColor = Trackable(value: backgroundColor)
            _titleLabelAppearance = Trackable(value: titleLabelAppearance)
            _subtitleLabelAppearance = Trackable(value: subtitleLabelAppearance)
            _avatarSize = Trackable(value: avatarSize)
            _separatorColor = Trackable(value: separatorColor)
            self.avatarRenderer = avatarRenderer
            self.avatarAppearance = avatarAppearance
        }

        public init(
            reference: PollResultsViewController.VoterCell.Appearance,
            backgroundColor: UIColor? = nil,
            titleLabelAppearance: LabelAppearance? = nil,
            subtitleLabelAppearance: LabelAppearance? = nil,
            avatarSize: CGSize? = nil,
            separatorColor: UIColor? = nil,
            avatarRenderer: AnyUserAvatarRendering? = nil,
            avatarAppearance: AvatarAppearance? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._titleLabelAppearance = Trackable(reference: reference, referencePath: \.titleLabelAppearance)
            self._subtitleLabelAppearance = Trackable(reference: reference, referencePath: \.subtitleLabelAppearance)
            self._avatarSize = Trackable(reference: reference, referencePath: \.avatarSize)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self.avatarRenderer = avatarRenderer ?? reference.avatarRenderer
            self.avatarAppearance = avatarAppearance ?? reference.avatarAppearance

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let titleLabelAppearance {
                self.titleLabelAppearance = titleLabelAppearance
            }
            if let subtitleLabelAppearance {
                self.subtitleLabelAppearance = subtitleLabelAppearance
            }
            if let avatarSize {
                self.avatarSize = avatarSize
            }
            if let separatorColor {
                self.separatorColor = separatorColor
            }
        }
    }
}
