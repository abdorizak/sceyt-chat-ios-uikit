//
//  CreatePollViewController+AddOptionCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension CreatePollViewController.AddOptionCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSections,
        titleLabelAppearance: .init(
            foregroundColor: .accent,
            font: Fonts.regular.withSize(16)
        ),
        iconTintColor: .accent
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, LabelAppearance>
        public var titleLabelAppearance: LabelAppearance

        @Trackable<Appearance, UIColor>
        public var iconTintColor: UIColor

        public init(
            backgroundColor: UIColor,
            titleLabelAppearance: LabelAppearance,
            iconTintColor: UIColor
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._titleLabelAppearance = Trackable(value: titleLabelAppearance)
            self._iconTintColor = Trackable(value: iconTintColor)
        }

        public init(
            reference: CreatePollViewController.AddOptionCell.Appearance,
            backgroundColor: UIColor? = nil,
            titleLabelAppearance: LabelAppearance? = nil,
            iconTintColor: UIColor? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._titleLabelAppearance = Trackable(reference: reference, referencePath: \.titleLabelAppearance)
            self._iconTintColor = Trackable(reference: reference, referencePath: \.iconTintColor)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let titleLabelAppearance {
                self.titleLabelAppearance = titleLabelAppearance
            }
            if let iconTintColor {
                self.iconTintColor = iconTintColor
            }
        }
    }
}
