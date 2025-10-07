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
        switchOptionCellAppearance: SwitchOptionCell.appearance
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

        public init(
            backgroundColor: UIColor,
            separatorColor: UIColor,
            linkFieldCellAppearance: LinkFieldCell.Appearance,
            actionCellAppearance: ActionCell.Appearance,
            switchOptionCellAppearance: SwitchOptionCell.Appearance
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._separatorColor = Trackable(value: separatorColor)
            self._linkFieldCellAppearance = Trackable(value: linkFieldCellAppearance)
            self._actionCellAppearance = Trackable(value: actionCellAppearance)
            self._switchOptionCellAppearance = Trackable(value: switchOptionCellAppearance)
        }

        public init(
            reference: ChannelInviteLinkViewController.Appearance,
            backgroundColor: UIColor? = nil,
            separatorColor: UIColor? = nil,
            linkFieldCellAppearance: LinkFieldCell.Appearance? = nil,
            actionCellAppearance: ActionCell.Appearance? = nil,
            switchOptionCellAppearance: SwitchOptionCell.Appearance? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._linkFieldCellAppearance = Trackable(reference: reference, referencePath: \.linkFieldCellAppearance)
            self._actionCellAppearance = Trackable(reference: reference, referencePath: \.actionCellAppearance)
            self._switchOptionCellAppearance = Trackable(reference: reference, referencePath: \.switchOptionCellAppearance)

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
        }
    }
}
