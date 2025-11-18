//
//  CreatePollViewController+SwitchOptionCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension CreatePollViewController.SwitchOptionCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSections,
        titleLabelAppearance: .init(
            foregroundColor: .primaryText,
            font: Fonts.regular.withSize(16)
        ),
        switchTintColor: .accent,
        separatorColor: .border
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, LabelAppearance>
        public var titleLabelAppearance: LabelAppearance

        @Trackable<Appearance, UIColor>
        public var switchTintColor: UIColor

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        public init(
            backgroundColor: UIColor,
            titleLabelAppearance: LabelAppearance,
            switchTintColor: UIColor,
            separatorColor: UIColor
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._titleLabelAppearance = Trackable(value: titleLabelAppearance)
            self._switchTintColor = Trackable(value: switchTintColor)
            self._separatorColor = Trackable(value: separatorColor)
        }

        public init(
            reference: CreatePollViewController.SwitchOptionCell.Appearance,
            backgroundColor: UIColor? = nil,
            titleLabelAppearance: LabelAppearance? = nil,
            switchTintColor: UIColor? = nil,
            separatorColor: UIColor? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._titleLabelAppearance = Trackable(reference: reference, referencePath: \.titleLabelAppearance)
            self._switchTintColor = Trackable(reference: reference, referencePath: \.switchTintColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let titleLabelAppearance {
                self.titleLabelAppearance = titleLabelAppearance
            }
            if let switchTintColor {
                self.switchTintColor = switchTintColor
            }
            if let separatorColor {
                self.separatorColor = separatorColor
            }
        }
    }
}
