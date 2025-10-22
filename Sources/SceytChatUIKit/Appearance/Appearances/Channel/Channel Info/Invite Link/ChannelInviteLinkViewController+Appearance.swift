//
//  ChannelInviteLinkViewController+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension ChannelInviteLinkViewController: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSecondary,
        separatorColor: .clear,
        linkFieldCellAppearance: LinkFieldCell.appearance,
        actionCellAppearance: ActionCell.appearance,
        switchOptionCellAppearance: SwitchOptionCell.appearance,
        titleText: L10n.Channel.InviteLink.title,
        linkDescriptionText: L10n.Channel.InviteLink.description,
        messagesDescriptionText: L10n.Channel.InviteLink.messagesDescription,
        showPreviousMessagesText: L10n.Channel.InviteLink.showPreviousMessages,
        shareText: L10n.Channel.InviteLink.share,
        resetLinkText: L10n.Channel.InviteLink.resetLink,
        openQRCodeText: L10n.Channel.InviteLink.openQRCode,
        linkCopiedText: L10n.Channel.InviteLink.linkCopied,
        cancelText: L10n.Channel.InviteLink.cancel,
        resetText: L10n.Channel.InviteLink.reset,
        resetAlertTitleText: L10n.Channel.InviteLink.resetAlertTitle,
        resetAlertMessageText: L10n.Channel.InviteLink.resetAlertMessage
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        @Trackable<Appearance, LinkFieldCell.Appearance>
        public var linkFieldCellAppearance: LinkFieldCell.Appearance

        @Trackable<Appearance, ActionCell.Appearance>
        public var actionCellAppearance: ActionCell.Appearance

        @Trackable<Appearance, SwitchOptionCell.Appearance>
        public var switchOptionCellAppearance: SwitchOptionCell.Appearance

        @Trackable<Appearance, String>
        public var titleText: String

        @Trackable<Appearance, String>
        public var linkDescriptionText: String

        @Trackable<Appearance, String>
        public var messagesDescriptionText: String

        @Trackable<Appearance, String>
        public var showPreviousMessagesText: String

        @Trackable<Appearance, String>
        public var shareText: String

        @Trackable<Appearance, String>
        public var resetLinkText: String

        @Trackable<Appearance, String>
        public var openQRCodeText: String

        @Trackable<Appearance, String>
        public var linkCopiedText: String

        @Trackable<Appearance, String>
        public var cancelText: String

        @Trackable<Appearance, String>
        public var resetText: String

        @Trackable<Appearance, String>
        public var resetAlertTitleText: String

        @Trackable<Appearance, String>
        public var resetAlertMessageText: String

        public init(
            backgroundColor: UIColor,
            separatorColor: UIColor,
            linkFieldCellAppearance: LinkFieldCell.Appearance,
            actionCellAppearance: ActionCell.Appearance,
            switchOptionCellAppearance: SwitchOptionCell.Appearance,
            titleText: String,
            linkDescriptionText: String,
            messagesDescriptionText: String,
            showPreviousMessagesText: String,
            shareText: String,
            resetLinkText: String,
            openQRCodeText: String,
            linkCopiedText: String,
            cancelText: String,
            resetText: String,
            resetAlertTitleText: String,
            resetAlertMessageText: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._separatorColor = Trackable(value: separatorColor)
            self._linkFieldCellAppearance = Trackable(value: linkFieldCellAppearance)
            self._actionCellAppearance = Trackable(value: actionCellAppearance)
            self._switchOptionCellAppearance = Trackable(value: switchOptionCellAppearance)
            self._titleText = Trackable(value: titleText)
            self._linkDescriptionText = Trackable(value: linkDescriptionText)
            self._messagesDescriptionText = Trackable(value: messagesDescriptionText)
            self._showPreviousMessagesText = Trackable(value: showPreviousMessagesText)
            self._shareText = Trackable(value: shareText)
            self._resetLinkText = Trackable(value: resetLinkText)
            self._openQRCodeText = Trackable(value: openQRCodeText)
            self._linkCopiedText = Trackable(value: linkCopiedText)
            self._cancelText = Trackable(value: cancelText)
            self._resetText = Trackable(value: resetText)
            self._resetAlertTitleText = Trackable(value: resetAlertTitleText)
            self._resetAlertMessageText = Trackable(value: resetAlertMessageText)
        }

        public init(
            reference: ChannelInviteLinkViewController.Appearance,
            backgroundColor: UIColor? = nil,
            separatorColor: UIColor? = nil,
            linkFieldCellAppearance: LinkFieldCell.Appearance? = nil,
            actionCellAppearance: ActionCell.Appearance? = nil,
            switchOptionCellAppearance: SwitchOptionCell.Appearance? = nil,
            titleText: String? = nil,
            linkDescriptionText: String? = nil,
            messagesDescriptionText: String? = nil,
            showPreviousMessagesText: String? = nil,
            shareText: String? = nil,
            resetLinkText: String? = nil,
            openQRCodeText: String? = nil,
            linkCopiedText: String? = nil,
            cancelText: String? = nil,
            resetText: String? = nil,
            resetAlertTitleText: String? = nil,
            resetAlertMessageText: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._linkFieldCellAppearance = Trackable(reference: reference, referencePath: \.linkFieldCellAppearance)
            self._actionCellAppearance = Trackable(reference: reference, referencePath: \.actionCellAppearance)
            self._switchOptionCellAppearance = Trackable(reference: reference, referencePath: \.switchOptionCellAppearance)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
            self._linkDescriptionText = Trackable(reference: reference, referencePath: \.linkDescriptionText)
            self._messagesDescriptionText = Trackable(reference: reference, referencePath: \.messagesDescriptionText)
            self._showPreviousMessagesText = Trackable(reference: reference, referencePath: \.showPreviousMessagesText)
            self._shareText = Trackable(reference: reference, referencePath: \.shareText)
            self._resetLinkText = Trackable(reference: reference, referencePath: \.resetLinkText)
            self._openQRCodeText = Trackable(reference: reference, referencePath: \.openQRCodeText)
            self._linkCopiedText = Trackable(reference: reference, referencePath: \.linkCopiedText)
            self._cancelText = Trackable(reference: reference, referencePath: \.cancelText)
            self._resetText = Trackable(reference: reference, referencePath: \.resetText)
            self._resetAlertTitleText = Trackable(reference: reference, referencePath: \.resetAlertTitleText)
            self._resetAlertMessageText = Trackable(reference: reference, referencePath: \.resetAlertMessageText)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let separatorColor {
                self.separatorColor = separatorColor
            }
            if let linkFieldCellAppearance {
                self.linkFieldCellAppearance = linkFieldCellAppearance
            }
            if let actionCellAppearance {
                self.actionCellAppearance = actionCellAppearance
            }
            if let switchOptionCellAppearance {
                self.switchOptionCellAppearance = switchOptionCellAppearance
            }
            if let titleText {
                self.titleText = titleText
            }
            if let linkDescriptionText {
                self.linkDescriptionText = linkDescriptionText
            }
            if let messagesDescriptionText {
                self.messagesDescriptionText = messagesDescriptionText
            }
            if let showPreviousMessagesText {
                self.showPreviousMessagesText = showPreviousMessagesText
            }
            if let shareText {
                self.shareText = shareText
            }
            if let resetLinkText {
                self.resetLinkText = resetLinkText
            }
            if let openQRCodeText {
                self.openQRCodeText = openQRCodeText
            }
            if let linkCopiedText {
                self.linkCopiedText = linkCopiedText
            }
            if let cancelText {
                self.cancelText = cancelText
            }
            if let resetText {
                self.resetText = resetText
            }
            if let resetAlertTitleText {
                self.resetAlertTitleText = resetAlertTitleText
            }
            if let resetAlertMessageText {
                self.resetAlertMessageText = resetAlertMessageText
            }
        }
    }
}
