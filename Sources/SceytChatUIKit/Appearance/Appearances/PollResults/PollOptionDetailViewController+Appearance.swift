//
//  PollOptionDetailViewController+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollOptionDetailViewController: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSecondary,
        separatorColor: .clear,
        voterCellAppearance: PollResultsViewController.VoterCell.appearance,
        titleText: "Poll Option",
        closeText: "Close"
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        @Trackable<Appearance, PollResultsViewController.VoterCell.Appearance>
        public var voterCellAppearance: PollResultsViewController.VoterCell.Appearance

        @Trackable<Appearance, String>
        public var titleText: String

        @Trackable<Appearance, String>
        public var closeText: String

        public init(
            backgroundColor: UIColor,
            separatorColor: UIColor,
            voterCellAppearance: PollResultsViewController.VoterCell.Appearance,
            titleText: String,
            closeText: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._separatorColor = Trackable(value: separatorColor)
            self._voterCellAppearance = Trackable(value: voterCellAppearance)
            self._titleText = Trackable(value: titleText)
            self._closeText = Trackable(value: closeText)
        }

        public init(
            reference: PollOptionDetailViewController.Appearance,
            backgroundColor: UIColor? = nil,
            separatorColor: UIColor? = nil,
            voterCellAppearance: PollResultsViewController.VoterCell.Appearance? = nil,
            titleText: String? = nil,
            closeText: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._voterCellAppearance = Trackable(reference: reference, referencePath: \.voterCellAppearance)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
            self._closeText = Trackable(reference: reference, referencePath: \.closeText)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let separatorColor {
                self.separatorColor = separatorColor
            }
            if let voterCellAppearance {
                self.voterCellAppearance = voterCellAppearance
            }
            if let titleText {
                self.titleText = titleText
            }
            if let closeText {
                self.closeText = closeText
            }
        }
    }
}
