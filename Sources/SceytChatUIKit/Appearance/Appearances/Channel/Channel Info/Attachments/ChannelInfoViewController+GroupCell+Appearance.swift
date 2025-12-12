//
//  ChannelInfoViewController+GroupCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt on 12.12.2024.
//  Copyright © 2024 Sceyt LLC. All rights reserved.
//

import UIKit

extension ChannelInfoViewController.GroupCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .background,
        selectedBackgroundColor: .surface2,
        separatorColor: .border,
        titleLabelAppearance: LabelAppearance(
            foregroundColor: .primaryText,
            font: Fonts.semiBold.withSize(16)
        ),
        descriptionLabelAppearance: LabelAppearance(
            foregroundColor: .secondaryText,
            font: Fonts.regular.withSize(13)
        ),
        avatarAppearance: AvatarAppearance.standard
    )
    
    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var selectedBackgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        @Trackable<Appearance, LabelAppearance>
        public var titleLabelAppearance: LabelAppearance

        @Trackable<Appearance, LabelAppearance>
        public var descriptionLabelAppearance: LabelAppearance

        @Trackable<Appearance, AvatarAppearance>
        public var avatarAppearance: AvatarAppearance

        public init(
            backgroundColor: UIColor,
            selectedBackgroundColor: UIColor,
            separatorColor: UIColor,
            titleLabelAppearance: LabelAppearance,
            descriptionLabelAppearance: LabelAppearance,
            avatarAppearance: AvatarAppearance
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._selectedBackgroundColor = Trackable(value: selectedBackgroundColor)
            self._separatorColor = Trackable(value: separatorColor)
            self._titleLabelAppearance = Trackable(value: titleLabelAppearance)
            self._descriptionLabelAppearance = Trackable(value: descriptionLabelAppearance)
            self._avatarAppearance = Trackable(value: avatarAppearance)
        }
        
        public init(
            reference: ChannelInfoViewController.GroupCell.Appearance,
            backgroundColor: UIColor? = nil,
            selectedBackgroundColor: UIColor? = nil,
            separatorColor: UIColor? = nil,
            titleLabelAppearance: LabelAppearance? = nil,
            descriptionLabelAppearance: LabelAppearance? = nil,
            avatarAppearance: AvatarAppearance? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._selectedBackgroundColor = Trackable(reference: reference, referencePath: \.selectedBackgroundColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._titleLabelAppearance = Trackable(reference: reference, referencePath: \.titleLabelAppearance)
            self._descriptionLabelAppearance = Trackable(reference: reference, referencePath: \.descriptionLabelAppearance)
            self._avatarAppearance = Trackable(reference: reference, referencePath: \.avatarAppearance)

            if let backgroundColor { self.backgroundColor = backgroundColor }
            if let selectedBackgroundColor { self.selectedBackgroundColor = selectedBackgroundColor }
            if let separatorColor { self.separatorColor = separatorColor }
            if let titleLabelAppearance { self.titleLabelAppearance = titleLabelAppearance }
            if let descriptionLabelAppearance { self.descriptionLabelAppearance = descriptionLabelAppearance }
            if let avatarAppearance { self.avatarAppearance = avatarAppearance }
        }
    }
}
