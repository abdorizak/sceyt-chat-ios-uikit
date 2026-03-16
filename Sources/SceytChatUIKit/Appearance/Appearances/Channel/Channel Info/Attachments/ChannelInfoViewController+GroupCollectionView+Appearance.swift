//
//  ChannelInfoViewController+GroupCollectionView+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt on 12.12.2024.
//  Copyright © 2024 Sceyt LLC. All rights reserved.
//

import UIKit

extension ChannelInfoViewController.GroupCollectionView: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .background,
        cellAppearance: SceytChatUIKit.Components.channelInfoGroupCell.appearance
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, ChannelInfoViewController.GroupCell.Appearance>
        public var cellAppearance: ChannelInfoViewController.GroupCell.Appearance

        public init(
            backgroundColor: UIColor,
            cellAppearance: ChannelInfoViewController.GroupCell.Appearance
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._cellAppearance = Trackable(value: cellAppearance)
        }

        public init(
            reference: ChannelInfoViewController.GroupCollectionView.Appearance,
            backgroundColor: UIColor? = nil,
            cellAppearance: ChannelInfoViewController.GroupCell.Appearance? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._cellAppearance = Trackable(reference: reference, referencePath: \.cellAppearance)

            if let backgroundColor { self.backgroundColor = backgroundColor }
            if let cellAppearance { self.cellAppearance = cellAppearance }
        }
    }
}
