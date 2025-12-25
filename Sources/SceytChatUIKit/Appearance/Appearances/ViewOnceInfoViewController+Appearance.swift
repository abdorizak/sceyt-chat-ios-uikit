//
//  ViewOnceInfoViewController+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension ViewOnceInfoViewController: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .background,
        titleLabelAppearance: LabelAppearance(
            foregroundColor: .primaryText,
            font: .systemFont(ofSize: 24, weight: .semibold),
            backgroundColor: .clear
        ),
        subtitleLabelAppearance: LabelAppearance(
            foregroundColor: .secondaryLabel,
            font: .systemFont(ofSize: 14, weight: .regular),
            backgroundColor: .clear
        ),
        okButtonAppearance: .init(
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
        titleText: L10n.ViewOnce.Info.title,
        subtitleText: L10n.ViewOnce.Info.description,
        okButtonTitle: L10n.Alert.Button.ok
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, LabelAppearance>
        public var titleLabelAppearance: LabelAppearance

        @Trackable<Appearance, LabelAppearance>
        public var subtitleLabelAppearance: LabelAppearance

        @Trackable<Appearance, ButtonAppearance>
        public var okButtonAppearance: ButtonAppearance

        @Trackable<Appearance, UIColor>
        public var closeButtonTintColor: UIColor

        @Trackable<Appearance, UIColor>
        public var closeButtonBackgroundColor: UIColor

        @Trackable<Appearance, String>
        public var titleText: String

        @Trackable<Appearance, String>
        public var subtitleText: String

        @Trackable<Appearance, String>
        public var okButtonTitle: String

        public init(
            backgroundColor: UIColor,
            titleLabelAppearance: LabelAppearance,
            subtitleLabelAppearance: LabelAppearance,
            okButtonAppearance: ButtonAppearance,
            closeButtonTintColor: UIColor,
            closeButtonBackgroundColor: UIColor,
            titleText: String,
            subtitleText: String,
            okButtonTitle: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._titleLabelAppearance = Trackable(value: titleLabelAppearance)
            self._subtitleLabelAppearance = Trackable(value: subtitleLabelAppearance)
            self._okButtonAppearance = Trackable(value: okButtonAppearance)
            self._closeButtonTintColor = Trackable(value: closeButtonTintColor)
            self._closeButtonBackgroundColor = Trackable(value: closeButtonBackgroundColor)
            self._titleText = Trackable(value: titleText)
            self._subtitleText = Trackable(value: subtitleText)
            self._okButtonTitle = Trackable(value: okButtonTitle)
        }

        public init(
            reference: ViewOnceInfoViewController.Appearance,
            backgroundColor: UIColor? = nil,
            titleLabelAppearance: LabelAppearance? = nil,
            subtitleLabelAppearance: LabelAppearance? = nil,
            okButtonAppearance: ButtonAppearance? = nil,
            closeButtonTintColor: UIColor? = nil,
            closeButtonBackgroundColor: UIColor? = nil,
            titleText: String? = nil,
            subtitleText: String? = nil,
            okButtonTitle: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._titleLabelAppearance = Trackable(reference: reference, referencePath: \.titleLabelAppearance)
            self._subtitleLabelAppearance = Trackable(reference: reference, referencePath: \.subtitleLabelAppearance)
            self._okButtonAppearance = Trackable(reference: reference, referencePath: \.okButtonAppearance)
            self._closeButtonTintColor = Trackable(reference: reference, referencePath: \.closeButtonTintColor)
            self._closeButtonBackgroundColor = Trackable(reference: reference, referencePath: \.closeButtonBackgroundColor)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
            self._subtitleText = Trackable(reference: reference, referencePath: \.subtitleText)
            self._okButtonTitle = Trackable(reference: reference, referencePath: \.okButtonTitle)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let titleLabelAppearance {
                self.titleLabelAppearance = titleLabelAppearance
            }
            if let subtitleLabelAppearance {
                self.subtitleLabelAppearance = subtitleLabelAppearance
            }
            if let okButtonAppearance {
                self.okButtonAppearance = okButtonAppearance
            }
            if let closeButtonTintColor {
                self.closeButtonTintColor = closeButtonTintColor
            }
            if let closeButtonBackgroundColor {
                self.closeButtonBackgroundColor = closeButtonBackgroundColor
            }
            if let titleText {
                self.titleText = titleText
            }
            if let subtitleText {
                self.subtitleText = subtitleText
            }
            if let okButtonTitle {
                self.okButtonTitle = okButtonTitle
            }
        }
    }
}
