//
//  PollResultsViewController+ShowMoreCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollResultsViewController.ShowMoreCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .clear,
        containerBackgroundColor: .backgroundSections,
        cornerRadius: 10,
        borderWidth: 0,
        borderColor: .clear,
        textColor: .systemBlue,
        font: Fonts.regular.withSize(16),
        showMoreButtonAppearance: .init(
            reference: ButtonAppearance.appearance,
            labelAppearance: .init(
                foregroundColor: .accent,
                font: Fonts.semiBold.withSize(16)
            )
        )
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

        @Trackable<Appearance, UIColor>
        public var textColor: UIColor

        @Trackable<Appearance, UIFont>
        public var font: UIFont

        @Trackable<Appearance, ButtonAppearance>
        public var showMoreButtonAppearance: ButtonAppearance

        public init(
            backgroundColor: UIColor,
            containerBackgroundColor: UIColor,
            cornerRadius: CGFloat,
            borderWidth: CGFloat,
            borderColor: UIColor,
            textColor: UIColor,
            font: UIFont,
            showMoreButtonAppearance: ButtonAppearance
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._containerBackgroundColor = Trackable(value: containerBackgroundColor)
            self._cornerRadius = Trackable(value: cornerRadius)
            self._borderWidth = Trackable(value: borderWidth)
            self._borderColor = Trackable(value: borderColor)
            self._textColor = Trackable(value: textColor)
            self._font = Trackable(value: font)
            self._showMoreButtonAppearance = Trackable(value: showMoreButtonAppearance)
        }

        public init(
            reference: PollResultsViewController.ShowMoreCell.Appearance,
            backgroundColor: UIColor? = nil,
            containerBackgroundColor: UIColor? = nil,
            cornerRadius: CGFloat? = nil,
            borderWidth: CGFloat? = nil,
            borderColor: UIColor? = nil,
            textColor: UIColor? = nil,
            font: UIFont? = nil,
            showMoreButtonAppearance: ButtonAppearance? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._containerBackgroundColor = Trackable(reference: reference, referencePath: \.containerBackgroundColor)
            self._cornerRadius = Trackable(reference: reference, referencePath: \.cornerRadius)
            self._borderWidth = Trackable(reference: reference, referencePath: \.borderWidth)
            self._borderColor = Trackable(reference: reference, referencePath: \.borderColor)
            self._textColor = Trackable(reference: reference, referencePath: \.textColor)
            self._font = Trackable(reference: reference, referencePath: \.font)
            self._showMoreButtonAppearance = Trackable(reference: reference, referencePath: \.showMoreButtonAppearance)

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
            if let textColor {
                self.textColor = textColor
            }
            if let font {
                self.font = font
            }
            if let showMoreButtonAppearance {
                self.showMoreButtonAppearance = showMoreButtonAppearance
            }
        }
    }
}
