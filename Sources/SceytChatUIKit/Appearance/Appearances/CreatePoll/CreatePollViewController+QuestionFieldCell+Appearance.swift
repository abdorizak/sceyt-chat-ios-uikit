//
//  CreatePollViewController+QuestionFieldCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension CreatePollViewController.QuestionFieldCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .clear,
        containerBackgroundColor: .backgroundSections,
        cornerRadius: 10,
        borderWidth: 0,
        borderColor: .clear,
        textViewAppearance: .init(
            foregroundColor: .primaryText,
            font: Fonts.regular.withSize(16)
        ),
        placeholderColor: .secondaryText,
        validationPattern: "^(?!\\s)[\\s\\S]{1,200}$"
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
        public var textViewAppearance: LabelAppearance

        @Trackable<Appearance, UIColor>
        public var placeholderColor: UIColor

        @Trackable<Appearance, String?>
        public var validationPattern: String?

        public init(
            backgroundColor: UIColor,
            containerBackgroundColor: UIColor,
            cornerRadius: CGFloat,
            borderWidth: CGFloat,
            borderColor: UIColor,
            textViewAppearance: LabelAppearance,
            placeholderColor: UIColor,
            validationPattern: String? = nil
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._containerBackgroundColor = Trackable(value: containerBackgroundColor)
            self._cornerRadius = Trackable(value: cornerRadius)
            self._borderWidth = Trackable(value: borderWidth)
            self._borderColor = Trackable(value: borderColor)
            self._textViewAppearance = Trackable(value: textViewAppearance)
            self._placeholderColor = Trackable(value: placeholderColor)
            self._validationPattern = Trackable(value: validationPattern)
        }

        public init(
            reference: CreatePollViewController.QuestionFieldCell.Appearance,
            backgroundColor: UIColor? = nil,
            containerBackgroundColor: UIColor? = nil,
            cornerRadius: CGFloat? = nil,
            borderWidth: CGFloat? = nil,
            borderColor: UIColor? = nil,
            textViewAppearance: LabelAppearance? = nil,
            placeholderColor: UIColor? = nil,
            validationPattern: String?? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._containerBackgroundColor = Trackable(reference: reference, referencePath: \.containerBackgroundColor)
            self._cornerRadius = Trackable(reference: reference, referencePath: \.cornerRadius)
            self._borderWidth = Trackable(reference: reference, referencePath: \.borderWidth)
            self._borderColor = Trackable(reference: reference, referencePath: \.borderColor)
            self._textViewAppearance = Trackable(reference: reference, referencePath: \.textViewAppearance)
            self._placeholderColor = Trackable(reference: reference, referencePath: \.placeholderColor)
            self._validationPattern = Trackable(reference: reference, referencePath: \.validationPattern)

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
            if let textViewAppearance {
                self.textViewAppearance = textViewAppearance
            }
            if let placeholderColor {
                self.placeholderColor = placeholderColor
            }
            if let validationPattern {
                self.validationPattern = validationPattern
            }
        }
    }
}
