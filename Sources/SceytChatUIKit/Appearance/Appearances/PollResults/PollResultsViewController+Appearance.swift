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
        closeButtonTintColor: .closeButtonTint,
        closeButtonBackgroundColor: .closeButtonBackground,
        titleText: "Poll Results",
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

        @Trackable<Appearance, UIColor>
        public var closeButtonTintColor: UIColor

        @Trackable<Appearance, UIColor>
        public var closeButtonBackgroundColor: UIColor

        @Trackable<Appearance, String>
        public var titleText: String

        @Trackable<Appearance, String>
        public var showMoreText: String

        public init(
            backgroundColor: UIColor,
            separatorColor: UIColor,
            questionCellAppearance: QuestionCell.Appearance,
            answerCellAppearance: AnswerCell.Appearance,
            voterCellAppearance: VoterCell.Appearance,
            showMoreCellAppearance: ShowMoreCell.Appearance,
            closeButtonTintColor: UIColor,
            closeButtonBackgroundColor: UIColor,
            titleText: String,
            showMoreText: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._separatorColor = Trackable(value: separatorColor)
            self._questionCellAppearance = Trackable(value: questionCellAppearance)
            self._answerCellAppearance = Trackable(value: answerCellAppearance)
            self._voterCellAppearance = Trackable(value: voterCellAppearance)
            self._showMoreCellAppearance = Trackable(value: showMoreCellAppearance)
            self._closeButtonTintColor = Trackable(value: closeButtonTintColor)
            self._closeButtonBackgroundColor = Trackable(value: closeButtonBackgroundColor)
            self._titleText = Trackable(value: titleText)
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
            closeButtonTintColor: UIColor? = nil,
            closeButtonBackgroundColor: UIColor? = nil,
            titleText: String? = nil,
            showMoreText: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._questionCellAppearance = Trackable(reference: reference, referencePath: \.questionCellAppearance)
            self._answerCellAppearance = Trackable(reference: reference, referencePath: \.answerCellAppearance)
            self._voterCellAppearance = Trackable(reference: reference, referencePath: \.voterCellAppearance)
            self._showMoreCellAppearance = Trackable(reference: reference, referencePath: \.showMoreCellAppearance)
            self._closeButtonTintColor = Trackable(reference: reference, referencePath: \.closeButtonTintColor)
            self._closeButtonBackgroundColor = Trackable(reference: reference, referencePath: \.closeButtonBackgroundColor)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
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
            if let closeButtonTintColor {
                self.closeButtonTintColor = closeButtonTintColor
            }
            if let closeButtonBackgroundColor {
                self.closeButtonBackgroundColor = closeButtonBackgroundColor
            }
            if let titleText {
                self.titleText = titleText
            }
            if let showMoreText {
                self.showMoreText = showMoreText
            }
        }
    }
}
