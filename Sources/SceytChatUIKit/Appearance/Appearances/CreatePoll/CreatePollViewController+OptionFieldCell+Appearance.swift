//
//  CreatePollViewController+OptionFieldCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension CreatePollViewController.OptionFieldCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .clear,
        containerBackgroundColor: .backgroundSections,
        cornerRadius: 10,
        borderWidth: 0,
        borderColor: .clear,
        textFieldAppearance: .init(
            foregroundColor: .primaryText,
            font: Fonts.regular.withSize(16)
        ),
        placeholderColor: .footnoteText,
        reorderImage: UIImage(systemName: "line.3.horizontal"),
        reorderIconTintColor: .iconInactive
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
        public var placeholderColor: UIColor

        @Trackable<Appearance, UIImage?>
        public var reorderImage: UIImage?

        @Trackable<Appearance, UIColor>
        public var reorderIconTintColor: UIColor

        public init(
            backgroundColor: UIColor,
            containerBackgroundColor: UIColor,
            cornerRadius: CGFloat,
            borderWidth: CGFloat,
            borderColor: UIColor,
            textFieldAppearance: LabelAppearance,
            placeholderColor: UIColor,
            reorderImage: UIImage?,
            reorderIconTintColor: UIColor
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._containerBackgroundColor = Trackable(value: containerBackgroundColor)
            self._cornerRadius = Trackable(value: cornerRadius)
            self._borderWidth = Trackable(value: borderWidth)
            self._borderColor = Trackable(value: borderColor)
            self._textFieldAppearance = Trackable(value: textFieldAppearance)
            self._placeholderColor = Trackable(value: placeholderColor)
            self._reorderImage = Trackable(value: reorderImage)
            self._reorderIconTintColor = Trackable(value: reorderIconTintColor)
        }

        public init(
            reference: CreatePollViewController.OptionFieldCell.Appearance,
            backgroundColor: UIColor? = nil,
            containerBackgroundColor: UIColor? = nil,
            cornerRadius: CGFloat? = nil,
            borderWidth: CGFloat? = nil,
            borderColor: UIColor? = nil,
            textFieldAppearance: LabelAppearance? = nil,
            placeholderColor: UIColor? = nil,
            reorderImage: UIImage?? = nil,
            reorderIconTintColor: UIColor? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._containerBackgroundColor = Trackable(reference: reference, referencePath: \.containerBackgroundColor)
            self._cornerRadius = Trackable(reference: reference, referencePath: \.cornerRadius)
            self._borderWidth = Trackable(reference: reference, referencePath: \.borderWidth)
            self._borderColor = Trackable(reference: reference, referencePath: \.borderColor)
            self._textFieldAppearance = Trackable(reference: reference, referencePath: \.textFieldAppearance)
            self._placeholderColor = Trackable(reference: reference, referencePath: \.placeholderColor)
            self._reorderImage = Trackable(reference: reference, referencePath: \.reorderImage)
            self._reorderIconTintColor = Trackable(reference: reference, referencePath: \.reorderIconTintColor)

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
            if let placeholderColor {
                self.placeholderColor = placeholderColor
            }
            if let reorderImage {
                self.reorderImage = reorderImage
            }
            if let reorderIconTintColor {
                self.reorderIconTintColor = reorderIconTintColor
            }
        }
    }
}
