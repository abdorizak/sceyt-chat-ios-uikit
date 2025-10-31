//
//  CreatePollViewController+Appearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension CreatePollViewController: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .backgroundSecondary,
        separatorColor: .border,
        questionFieldCellAppearance: QuestionFieldCell.appearance,
        optionFieldCellAppearance: OptionFieldCell.appearance,
        switchOptionCellAppearance: SwitchOptionCell.appearance,
        addOptionCellAppearance: AddOptionCell.appearance,
        titleText: "Poll",
        questionDescriptionText: "QUESTION",
        optionsHeaderText: "OPTIONS",
        parametersHeaderText: "PARAMETERS",
        questionPlaceholderText: "Add question",
        optionPlaceholderText: { _ in "Add" },
        addOptionText: "Add an option",
        allowMultipleAnswersText: "Multiple votes",
        showVoterNamesText: "Anonymous poll",
        allowAddingOptionsText: "Can't retract votes",
        cancelText: "Cancel",
        createText: "Send",
        discardAlertTitle: nil,
        discardAlertMessage: "Are you sure you want to discard your poll?",
        discardAlertCancelText: "Keep Editing",
        discardAlertDiscardText: "Discard Poll",
        maxOptionsCount: 12
    )

    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor

        @Trackable<Appearance, UIColor>
        public var separatorColor: UIColor

        @Trackable<Appearance, QuestionFieldCell.Appearance>
        public var questionFieldCellAppearance: QuestionFieldCell.Appearance

        @Trackable<Appearance, OptionFieldCell.Appearance>
        public var optionFieldCellAppearance: OptionFieldCell.Appearance

        @Trackable<Appearance, SwitchOptionCell.Appearance>
        public var switchOptionCellAppearance: SwitchOptionCell.Appearance

        @Trackable<Appearance, AddOptionCell.Appearance>
        public var addOptionCellAppearance: AddOptionCell.Appearance

        @Trackable<Appearance, String>
        public var titleText: String

        @Trackable<Appearance, String>
        public var questionDescriptionText: String

        @Trackable<Appearance, String>
        public var optionsHeaderText: String

        @Trackable<Appearance, String>
        public var parametersHeaderText: String

        @Trackable<Appearance, String>
        public var questionPlaceholderText: String

        public var optionPlaceholderText: (Int) -> String

        @Trackable<Appearance, String>
        public var addOptionText: String

        @Trackable<Appearance, String>
        public var allowMultipleAnswersText: String

        @Trackable<Appearance, String>
        public var showVoterNamesText: String

        @Trackable<Appearance, String>
        public var allowAddingOptionsText: String

        @Trackable<Appearance, String>
        public var cancelText: String

        @Trackable<Appearance, String>
        public var createText: String

        @Trackable<Appearance, String?>
        public var discardAlertTitle: String?

        @Trackable<Appearance, String>
        public var discardAlertMessage: String

        @Trackable<Appearance, String>
        public var discardAlertCancelText: String

        @Trackable<Appearance, String>
        public var discardAlertDiscardText: String

        @Trackable<Appearance, Int>
        public var maxOptionsCount: Int

        public init(
            backgroundColor: UIColor,
            separatorColor: UIColor,
            questionFieldCellAppearance: QuestionFieldCell.Appearance,
            optionFieldCellAppearance: OptionFieldCell.Appearance,
            switchOptionCellAppearance: SwitchOptionCell.Appearance,
            addOptionCellAppearance: AddOptionCell.Appearance,
            titleText: String,
            questionDescriptionText: String,
            optionsHeaderText: String,
            parametersHeaderText: String,
            questionPlaceholderText: String,
            optionPlaceholderText: @escaping (Int) -> String,
            addOptionText: String,
            allowMultipleAnswersText: String,
            showVoterNamesText: String,
            allowAddingOptionsText: String,
            cancelText: String,
            createText: String,
            discardAlertTitle: String?,
            discardAlertMessage: String,
            discardAlertCancelText: String,
            discardAlertDiscardText: String,
            maxOptionsCount: Int
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._separatorColor = Trackable(value: separatorColor)
            self._questionFieldCellAppearance = Trackable(value: questionFieldCellAppearance)
            self._optionFieldCellAppearance = Trackable(value: optionFieldCellAppearance)
            self._switchOptionCellAppearance = Trackable(value: switchOptionCellAppearance)
            self._addOptionCellAppearance = Trackable(value: addOptionCellAppearance)
            self._titleText = Trackable(value: titleText)
            self._questionDescriptionText = Trackable(value: questionDescriptionText)
            self._optionsHeaderText = Trackable(value: optionsHeaderText)
            self._parametersHeaderText = Trackable(value: parametersHeaderText)
            self._questionPlaceholderText = Trackable(value: questionPlaceholderText)
            self.optionPlaceholderText = optionPlaceholderText
            self._addOptionText = Trackable(value: addOptionText)
            self._allowMultipleAnswersText = Trackable(value: allowMultipleAnswersText)
            self._showVoterNamesText = Trackable(value: showVoterNamesText)
            self._allowAddingOptionsText = Trackable(value: allowAddingOptionsText)
            self._cancelText = Trackable(value: cancelText)
            self._createText = Trackable(value: createText)
            self._discardAlertTitle = Trackable(value: discardAlertTitle)
            self._discardAlertMessage = Trackable(value: discardAlertMessage)
            self._discardAlertCancelText = Trackable(value: discardAlertCancelText)
            self._discardAlertDiscardText = Trackable(value: discardAlertDiscardText)
            self._maxOptionsCount = Trackable(value: maxOptionsCount)
        }

        public init(
            reference: CreatePollViewController.Appearance,
            backgroundColor: UIColor? = nil,
            separatorColor: UIColor? = nil,
            questionFieldCellAppearance: QuestionFieldCell.Appearance? = nil,
            optionFieldCellAppearance: OptionFieldCell.Appearance? = nil,
            switchOptionCellAppearance: SwitchOptionCell.Appearance? = nil,
            addOptionCellAppearance: AddOptionCell.Appearance? = nil,
            titleText: String? = nil,
            questionDescriptionText: String? = nil,
            optionsHeaderText: String? = nil,
            parametersHeaderText: String? = nil,
            questionPlaceholderText: String? = nil,
            optionPlaceholderText: ((Int) -> String)? = nil,
            addOptionText: String? = nil,
            allowMultipleAnswersText: String? = nil,
            showVoterNamesText: String? = nil,
            allowAddingOptionsText: String? = nil,
            cancelText: String? = nil,
            createText: String? = nil,
            discardAlertTitle: String?? = nil,
            discardAlertMessage: String? = nil,
            discardAlertCancelText: String? = nil,
            discardAlertDiscardText: String? = nil,
            maxOptionsCount: Int? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
            self._questionFieldCellAppearance = Trackable(reference: reference, referencePath: \.questionFieldCellAppearance)
            self._optionFieldCellAppearance = Trackable(reference: reference, referencePath: \.optionFieldCellAppearance)
            self._switchOptionCellAppearance = Trackable(reference: reference, referencePath: \.switchOptionCellAppearance)
            self._addOptionCellAppearance = Trackable(reference: reference, referencePath: \.addOptionCellAppearance)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
            self._questionDescriptionText = Trackable(reference: reference, referencePath: \.questionDescriptionText)
            self._optionsHeaderText = Trackable(reference: reference, referencePath: \.optionsHeaderText)
            self._parametersHeaderText = Trackable(reference: reference, referencePath: \.parametersHeaderText)
            self._questionPlaceholderText = Trackable(reference: reference, referencePath: \.questionPlaceholderText)
            self.optionPlaceholderText = optionPlaceholderText ?? reference.optionPlaceholderText
            self._addOptionText = Trackable(reference: reference, referencePath: \.addOptionText)
            self._allowMultipleAnswersText = Trackable(reference: reference, referencePath: \.allowMultipleAnswersText)
            self._showVoterNamesText = Trackable(reference: reference, referencePath: \.showVoterNamesText)
            self._allowAddingOptionsText = Trackable(reference: reference, referencePath: \.allowAddingOptionsText)
            self._cancelText = Trackable(reference: reference, referencePath: \.cancelText)
            self._createText = Trackable(reference: reference, referencePath: \.createText)
            self._discardAlertTitle = Trackable(reference: reference, referencePath: \.discardAlertTitle)
            self._discardAlertMessage = Trackable(reference: reference, referencePath: \.discardAlertMessage)
            self._discardAlertCancelText = Trackable(reference: reference, referencePath: \.discardAlertCancelText)
            self._discardAlertDiscardText = Trackable(reference: reference, referencePath: \.discardAlertDiscardText)
            self._maxOptionsCount = Trackable(reference: reference, referencePath: \.maxOptionsCount)

            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let separatorColor {
                self.separatorColor = separatorColor
            }
            if let questionFieldCellAppearance {
                self.questionFieldCellAppearance = questionFieldCellAppearance
            }
            if let optionFieldCellAppearance {
                self.optionFieldCellAppearance = optionFieldCellAppearance
            }
            if let switchOptionCellAppearance {
                self.switchOptionCellAppearance = switchOptionCellAppearance
            }
            if let addOptionCellAppearance {
                self.addOptionCellAppearance = addOptionCellAppearance
            }
            if let titleText {
                self.titleText = titleText
            }
            if let questionDescriptionText {
                self.questionDescriptionText = questionDescriptionText
            }
            if let optionsHeaderText {
                self.optionsHeaderText = optionsHeaderText
            }
            if let parametersHeaderText {
                self.parametersHeaderText = parametersHeaderText
            }
            if let questionPlaceholderText {
                self.questionPlaceholderText = questionPlaceholderText
            }
            if let addOptionText {
                self.addOptionText = addOptionText
            }
            if let allowMultipleAnswersText {
                self.allowMultipleAnswersText = allowMultipleAnswersText
            }
            if let showVoterNamesText {
                self.showVoterNamesText = showVoterNamesText
            }
            if let allowAddingOptionsText {
                self.allowAddingOptionsText = allowAddingOptionsText
            }
            if let cancelText {
                self.cancelText = cancelText
            }
            if let createText {
                self.createText = createText
            }
            if discardAlertTitle != nil {
                self.discardAlertTitle = discardAlertTitle!
            }
            if let discardAlertMessage {
                self.discardAlertMessage = discardAlertMessage
            }
            if let discardAlertCancelText {
                self.discardAlertCancelText = discardAlertCancelText
            }
            if let discardAlertDiscardText {
                self.discardAlertDiscardText = discardAlertDiscardText
            }
            if let maxOptionsCount {
                self.maxOptionsCount = maxOptionsCount
            }
        }
    }
}
