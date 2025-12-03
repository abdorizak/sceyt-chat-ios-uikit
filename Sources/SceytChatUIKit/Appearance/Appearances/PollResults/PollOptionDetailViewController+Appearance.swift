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
        voteCountInfoCellAppearance: PollOptionDetailViewController.VoteCountInfoCell.appearance,
        voterCellAppearance: PollResultsViewController.VoterCell.appearance,
        titleText: L10n.Poll.OptionDetail.title,
        closeText: L10n.Poll.OptionDetail.close
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        @Trackable<Appearance, PollOptionDetailViewController.VoteCountInfoCell.Appearance>
        public var voteCountInfoCellAppearance: PollOptionDetailViewController.VoteCountInfoCell.Appearance

        @Trackable<Appearance, PollResultsViewController.VoterCell.Appearance>
        public var voterCellAppearance: PollResultsViewController.VoterCell.Appearance

        @Trackable<Appearance, String>
        public var titleText: String

        @Trackable<Appearance, String>
        public var closeText: String

        public init(
            backgroundColor: UIColor,
            separatorColor: UIColor,
            voteCountInfoCellAppearance: PollOptionDetailViewController.VoteCountInfoCell.Appearance,
            voterCellAppearance: PollResultsViewController.VoterCell.Appearance,
            titleText: String,
            closeText: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._separatorColor = Trackable(value: separatorColor)
            self._voteCountInfoCellAppearance = Trackable(value: voteCountInfoCellAppearance)
            self._voterCellAppearance = Trackable(value: voterCellAppearance)
            self._titleText = Trackable(value: titleText)
            self._closeText = Trackable(value: closeText)
        }

        public init(
            reference: PollOptionDetailViewController.Appearance,
            backgroundColor: UIColor? = nil,
            separatorColor: UIColor? = nil,
            voteCountInfoCellAppearance: PollOptionDetailViewController.VoteCountInfoCell.Appearance? = nil,
            voterCellAppearance: PollResultsViewController.VoterCell.Appearance? = nil,
            titleText: String? = nil,
            closeText: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._voteCountInfoCellAppearance = Trackable(reference: reference, referencePath: \.voteCountInfoCellAppearance)
            self._voterCellAppearance = Trackable(reference: reference, referencePath: \.voterCellAppearance)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
            self._closeText = Trackable(reference: reference, referencePath: \.closeText)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let separatorColor {
                self.separatorColor = separatorColor
            }
            if let voteCountInfoCellAppearance {
                self.voteCountInfoCellAppearance = voteCountInfoCellAppearance
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
