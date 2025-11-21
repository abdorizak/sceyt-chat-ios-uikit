//
//  ChannelInviteLinkViewController+LinkFieldCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension ChannelInviteLinkViewController.LinkFieldCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSections,
        containerBackgroundColor: .backgroundSections,
        cornerRadius: 8,
        borderWidth: 1,
        borderColor: .clear,
        textFieldAppearance: .init(
            foregroundColor: .primaryText,
            font: Fonts.regular.withSize(16)
        ),
        buttonTitleColor: .accent,
        buttonFont: Fonts.semiBold.withSize(14),
        copyImage: .messageActionCopy
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var containerBackgroundColor: UIColor

        @Trackable<Appearance, CGFloat>
        public var cornerRadius: CGFloat

        @Trackable<Appearance, CGFloat>
        public var borderWidth: CGFloat

        @Trackable<Appearance, UIColor>
        public var borderColor: UIColor

        @Trackable<Appearance, LabelAppearance>
        public var textFieldAppearance: LabelAppearance

        @Trackable<Appearance, UIColor>
        public var buttonTitleColor: UIColor

        @Trackable<Appearance, UIFont>
        public var buttonFont: UIFont

        @Trackable<Appearance, UIImage>
        public var copyImage: UIImage

        public init(
            backgroundColor: UIColor,
            containerBackgroundColor: UIColor,
            cornerRadius: CGFloat,
            borderWidth: CGFloat,
            borderColor: UIColor,
            textFieldAppearance: LabelAppearance,
            buttonTitleColor: UIColor,
            buttonFont: UIFont,
            copyImage: UIImage
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._containerBackgroundColor = Trackable(value: containerBackgroundColor)
            self._cornerRadius = Trackable(value: cornerRadius)
            self._borderWidth = Trackable(value: borderWidth)
            self._borderColor = Trackable(value: borderColor)
            self._textFieldAppearance = Trackable(value: textFieldAppearance)
            self._buttonTitleColor = Trackable(value: buttonTitleColor)
            self._buttonFont = Trackable(value: buttonFont)
            self._copyImage = Trackable(value: copyImage)
        }

        public init(
            reference: ChannelInviteLinkViewController.LinkFieldCell.Appearance,
            backgroundColor: UIColor? = nil,
            containerBackgroundColor: UIColor? = nil,
            cornerRadius: CGFloat? = nil,
            borderWidth: CGFloat? = nil,
            borderColor: UIColor? = nil,
            textFieldAppearance: LabelAppearance? = nil,
            buttonTitleColor: UIColor? = nil,
            buttonFont: UIFont? = nil,
            copyImage: UIImage? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._containerBackgroundColor = Trackable(reference: reference, referencePath: \.containerBackgroundColor)
            self._cornerRadius = Trackable(reference: reference, referencePath: \.cornerRadius)
            self._borderWidth = Trackable(reference: reference, referencePath: \.borderWidth)
            self._borderColor = Trackable(reference: reference, referencePath: \.borderColor)
            self._textFieldAppearance = Trackable(reference: reference, referencePath: \.textFieldAppearance)
            self._buttonTitleColor = Trackable(reference: reference, referencePath: \.buttonTitleColor)
            self._buttonFont = Trackable(reference: reference, referencePath: \.buttonFont)
            self._copyImage = Trackable(reference: reference, referencePath: \.copyImage)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let containerBackgroundColor {
                self.containerBackgroundColor = containerBackgroundColor
            }
            if let cornerRadius {
                self.cornerRadius = cornerRadius
            }
            if let borderWidth {
                self.borderWidth = borderWidth
            }
            if let borderColor {
                self.borderColor = borderColor
            }
            if let textFieldAppearance {
                self.textFieldAppearance = textFieldAppearance
            }
            if let buttonTitleColor {
                self.buttonTitleColor = buttonTitleColor
            }
            if let buttonFont {
                self.buttonFont = buttonFont
            }
            if let copyImage {
                self.copyImage = copyImage
            }
        }
    }
}
