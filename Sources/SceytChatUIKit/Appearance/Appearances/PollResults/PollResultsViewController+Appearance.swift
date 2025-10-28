//
//  PollResultsViewController+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension PollResultsViewController: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSecondary,
        separatorColor: .clear,
        questionCellAppearance: QuestionCell.appearance,
        answerCellAppearance: AnswerCell.appearance,
        voterCellAppearance: VoterCell.appearance,
        showMoreCellAppearance: ShowMoreCell.appearance,
        titleText: "Poll Results",
        closeText: "Close",
        singleVoteText: "1 vote",
        multipleVotesText: { count in "\(count) votes" },
        showMoreText: "Show More"
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        @Trackable<Appearance, QuestionCell.Appearance>
        public var questionCellAppearance: QuestionCell.Appearance

        @Trackable<Appearance, AnswerCell.Appearance>
        public var answerCellAppearance: AnswerCell.Appearance

        @Trackable<Appearance, VoterCell.Appearance>
        public var voterCellAppearance: VoterCell.Appearance

        @Trackable<Appearance, ShowMoreCell.Appearance>
        public var showMoreCellAppearance: ShowMoreCell.Appearance

        @Trackable<Appearance, String>
        public var titleText: String

        @Trackable<Appearance, String>
        public var closeText: String

        @Trackable<Appearance, String>
        public var singleVoteText: String

        public var multipleVotesText: (Int) -> String

        @Trackable<Appearance, String>
        public var showMoreText: String

        public init(
            backgroundColor: UIColor,
            separatorColor: UIColor,
            questionCellAppearance: QuestionCell.Appearance,
            answerCellAppearance: AnswerCell.Appearance,
            voterCellAppearance: VoterCell.Appearance,
            showMoreCellAppearance: ShowMoreCell.Appearance,
            titleText: String,
            closeText: String,
            singleVoteText: String,
            multipleVotesText: @escaping (Int) -> String,
            showMoreText: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._separatorColor = Trackable(value: separatorColor)
            self._questionCellAppearance = Trackable(value: questionCellAppearance)
            self._answerCellAppearance = Trackable(value: answerCellAppearance)
            self._voterCellAppearance = Trackable(value: voterCellAppearance)
            self._showMoreCellAppearance = Trackable(value: showMoreCellAppearance)
            self._titleText = Trackable(value: titleText)
            self._closeText = Trackable(value: closeText)
            self._singleVoteText = Trackable(value: singleVoteText)
            self.multipleVotesText = multipleVotesText
            self._showMoreText = Trackable(value: showMoreText)
        }

        public init(
            reference: PollResultsViewController.Appearance,
            backgroundColor: UIColor? = nil,
            separatorColor: UIColor? = nil,
            questionCellAppearance: QuestionCell.Appearance? = nil,
            answerCellAppearance: AnswerCell.Appearance? = nil,
            voterCellAppearance: VoterCell.Appearance? = nil,
            showMoreCellAppearance: ShowMoreCell.Appearance? = nil,
            titleText: String? = nil,
            closeText: String? = nil,
            singleVoteText: String? = nil,
            multipleVotesText: ((Int) -> String)? = nil,
            showMoreText: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._questionCellAppearance = Trackable(reference: reference, referencePath: \.questionCellAppearance)
            self._answerCellAppearance = Trackable(reference: reference, referencePath: \.answerCellAppearance)
            self._voterCellAppearance = Trackable(reference: reference, referencePath: \.voterCellAppearance)
            self._showMoreCellAppearance = Trackable(reference: reference, referencePath: \.showMoreCellAppearance)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
            self._closeText = Trackable(reference: reference, referencePath: \.closeText)
            self._singleVoteText = Trackable(reference: reference, referencePath: \.singleVoteText)
            self.multipleVotesText = multipleVotesText ?? reference.multipleVotesText
            self._showMoreText = Trackable(reference: reference, referencePath: \.showMoreText)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let separatorColor {
                self.separatorColor = separatorColor
            }
            if let questionCellAppearance {
                self.questionCellAppearance = questionCellAppearance
            }
            if let answerCellAppearance {
                self.answerCellAppearance = answerCellAppearance
            }
            if let voterCellAppearance {
                self.voterCellAppearance = voterCellAppearance
            }
            if let showMoreCellAppearance {
                self.showMoreCellAppearance = showMoreCellAppearance
            }
            if let titleText {
                self.titleText = titleText
            }
            if let closeText {
                self.closeText = closeText
            }
            if let singleVoteText {
                self.singleVoteText = singleVoteText
            }
            if let showMoreText {
                self.showMoreText = showMoreText
            }
        }
    }
}
