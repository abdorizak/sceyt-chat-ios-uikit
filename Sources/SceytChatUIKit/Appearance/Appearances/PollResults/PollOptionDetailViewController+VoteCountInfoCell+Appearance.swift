//
//  PollOptionDetailViewController+VoteCountInfoCell+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollOptionDetailViewController.VoteCountInfoCell: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .clear,
        containerBackgroundColor: .backgroundSections,
        cornerRadius: 10,
        borderWidth: 0,
        borderColor: .clear,
        infoLabelAppearance: .init(
            foregroundColor: .primaryText,
            font: Fonts.semiBold.withSize(16)
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

        @Trackable<Appearance, LabelAppearance>
        public var infoLabelAppearance: LabelAppearance

        public init(
            backgroundColor: UIColor,
            containerBackgroundColor: UIColor,
            cornerRadius: CGFloat,
            borderWidth: CGFloat,
            borderColor: UIColor,
            infoLabelAppearance: LabelAppearance
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._containerBackgroundColor = Trackable(value: containerBackgroundColor)
            self._cornerRadius = Trackable(value: cornerRadius)
            self._borderWidth = Trackable(value: borderWidth)
            self._borderColor = Trackable(value: borderColor)
            self._infoLabelAppearance = Trackable(value: infoLabelAppearance)
        }

        public init(
            reference: PollOptionDetailViewController.VoteCountInfoCell.Appearance,
            backgroundColor: UIColor? = nil,
            containerBackgroundColor: UIColor? = nil,
            cornerRadius: CGFloat? = nil,
            borderWidth: CGFloat? = nil,
            borderColor: UIColor? = nil,
            infoLabelAppearance: LabelAppearance? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._containerBackgroundColor = Trackable(reference: reference, referencePath: \.containerBackgroundColor)
            self._cornerRadius = Trackable(reference: reference, referencePath: \.cornerRadius)
            self._borderWidth = Trackable(reference: reference, referencePath: \.borderWidth)
            self._borderColor = Trackable(reference: reference, referencePath: \.borderColor)
            self._infoLabelAppearance = Trackable(reference: reference, referencePath: \.infoLabelAppearance)

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
            if let infoLabelAppearance {
                self.infoLabelAppearance = infoLabelAppearance
            }
        }
    }
}
