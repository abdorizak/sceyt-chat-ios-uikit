//
//  QRCodeViewController+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension QRCodeViewController: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .background,
        qrCodeBackgroundColor: .white,
        qrCodeSize: CGSize(width: 250, height: 250),
        qrCodePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
        titleLabelAppearance: .init(
            foregroundColor: .primaryText,
            font: Fonts.semiBold.withSize(16),
            backgroundColor: .clear
        ),
        linkLabelAppearance: .init(
            foregroundColor: .footnoteText,
            font: Fonts.regular.withSize(14),
            backgroundColor: .clear
        ),
        shareButtonAppearance: .init(
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
        titleText: L10n.Channel.Profile.qrCodeTitle,
        shareButtonTitle: L10n.Channel.Profile.qrCodeShare,
        linkLabelText: L10n.Channel.Profile.qrCodeDescription
    )

    public struct Appearance {

        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var qrCodeBackgroundColor: UIColor

        @Trackable<Appearance, CGSize>
        public var qrCodeSize: CGSize

        @Trackable<Appearance, UIEdgeInsets>
        public var qrCodePadding: UIEdgeInsets

        @Trackable<Appearance, LabelAppearance>
        public var titleLabelAppearance: LabelAppearance

        @Trackable<Appearance, LabelAppearance>
        public var linkLabelAppearance: LabelAppearance

        @Trackable<Appearance, ButtonAppearance>
        public var shareButtonAppearance: ButtonAppearance

        @Trackable<Appearance, String>
        public var titleText: String

        @Trackable<Appearance, String>
        public var shareButtonTitle: String

        @Trackable<Appearance, String>
        public var linkLabelText: String

        public init(
            backgroundColor: UIColor,
            qrCodeBackgroundColor: UIColor,
            qrCodeSize: CGSize,
            qrCodePadding: UIEdgeInsets,
            titleLabelAppearance: LabelAppearance,
            linkLabelAppearance: LabelAppearance,
            shareButtonAppearance: ButtonAppearance,
            titleText: String,
            shareButtonTitle: String,
            linkLabelText: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._qrCodeBackgroundColor = Trackable(value: qrCodeBackgroundColor)
            self._qrCodeSize = Trackable(value: qrCodeSize)
            self._qrCodePadding = Trackable(value: qrCodePadding)
            self._titleLabelAppearance = Trackable(value: titleLabelAppearance)
            self._linkLabelAppearance = Trackable(value: linkLabelAppearance)
            self._shareButtonAppearance = Trackable(value: shareButtonAppearance)
            self._titleText = Trackable(value: titleText)
            self._shareButtonTitle = Trackable(value: shareButtonTitle)
            self._linkLabelText = Trackable(value: linkLabelText)
        }

        public init(
            reference: QRCodeViewController.Appearance,
            backgroundColor: UIColor? = nil,
            qrCodeBackgroundColor: UIColor? = nil,
            qrCodeSize: CGSize? = nil,
            qrCodePadding: UIEdgeInsets? = nil,
            titleLabelAppearance: LabelAppearance? = nil,
            linkLabelAppearance: LabelAppearance? = nil,
            shareButtonAppearance: ButtonAppearance? = nil,
            titleText: String? = nil,
            shareButtonTitle: String? = nil,
            linkLabelText: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._qrCodeBackgroundColor = Trackable(reference: reference, referencePath: \.qrCodeBackgroundColor)
            self._qrCodeSize = Trackable(reference: reference, referencePath: \.qrCodeSize)
            self._qrCodePadding = Trackable(reference: reference, referencePath: \.qrCodePadding)
            self._titleLabelAppearance = Trackable(reference: reference, referencePath: \.titleLabelAppearance)
            self._linkLabelAppearance = Trackable(reference: reference, referencePath: \.linkLabelAppearance)
            self._shareButtonAppearance = Trackable(reference: reference, referencePath: \.shareButtonAppearance)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
            self._shareButtonTitle = Trackable(reference: reference, referencePath: \.shareButtonTitle)
            self._linkLabelText = Trackable(reference: reference, referencePath: \.linkLabelText)

            if let backgroundColor { self.backgroundColor = backgroundColor }
            if let qrCodeBackgroundColor { self.qrCodeBackgroundColor = qrCodeBackgroundColor }
            if let qrCodeSize { self.qrCodeSize = qrCodeSize }
            if let qrCodePadding { self.qrCodePadding = qrCodePadding }
            if let titleLabelAppearance { self.titleLabelAppearance = titleLabelAppearance }
            if let linkLabelAppearance { self.linkLabelAppearance = linkLabelAppearance }
            if let shareButtonAppearance { self.shareButtonAppearance = shareButtonAppearance }
            if let titleText { self.titleText = titleText }
            if let shareButtonTitle { self.shareButtonTitle = shareButtonTitle }
            if let linkLabelText { self.linkLabelText = linkLabelText }
        }
    }
}
