//
//  PollViewAppearance.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

public class PollViewAppearance: AppearanceProviding {

    public var appearance: PollViewAppearance {
        parentAppearance ?? Self.appearance
    }

    public var parentAppearance: PollViewAppearance?

    public static var appearance = PollViewAppearance(
        progressBarBackground: DefaultColors.accent,
        progressBarForeground: UIColor.systemGray5,
        questionTextStyle: .init(
            foregroundColor: .label,
            font: Fonts.semiBold.withSize(16)
        ),
        pollTypeTextStyle: .init(
            foregroundColor: .secondaryLabel,
            font: Fonts.regular.withSize(13)
        ),
        optionTextStyle: .init(
            foregroundColor: .label,
            font: Fonts.regular.withSize(15)
        ),
        voteCountTextStyle: .init(
            foregroundColor: .secondaryLabel,
            font: Fonts.semiBold.withSize(13)
        ),
        checkboxStyle: .init(
            size: 22,
            spacing: 12,
            selectedColor: .systemBlue,
            unselectedColor: .systemGray4,
            borderWidth: 2,
            cornerRadius: 4
        ),
        voterAvatarStyle: .init(
            size: 20.0,
            borderWidth: 1,
            spacing: -8
        ),
    )

    // MARK: - Colors

    @Trackable<PollViewAppearance, UIColor>
    public var progressBarBackground: UIColor

    @Trackable<PollViewAppearance, UIColor>
    public var progressBarForeground: UIColor

    // MARK: - Text Styles

    @Trackable<PollViewAppearance, LabelAppearance>
    public var questionTextStyle: LabelAppearance

    @Trackable<PollViewAppearance, LabelAppearance>
    public var pollTypeTextStyle: LabelAppearance

    @Trackable<PollViewAppearance, LabelAppearance>
    public var optionTextStyle: LabelAppearance
    
    @Trackable<PollViewAppearance, LabelAppearance>
    public var voteCountTextStyle: LabelAppearance

    // MARK: - Component Styles

    @Trackable<PollViewAppearance, CheckboxStyle>
    public var checkboxStyle: CheckboxStyle

    @Trackable<PollViewAppearance, AvatarStyle>
    public var voterAvatarStyle: AvatarStyle

    // MARK: - Initializers
    
    public init(
        progressBarBackground: UIColor,
        progressBarForeground: UIColor,
        questionTextStyle: LabelAppearance,
        pollTypeTextStyle: LabelAppearance,
        optionTextStyle: LabelAppearance,
        voteCountTextStyle: LabelAppearance,
        checkboxStyle: CheckboxStyle,
        voterAvatarStyle: AvatarStyle
    ) {
        self._progressBarBackground = Trackable(value: progressBarBackground)
        self._progressBarForeground = Trackable(value: progressBarForeground)
        self._questionTextStyle = Trackable(value: questionTextStyle)
        self._pollTypeTextStyle = Trackable(value: pollTypeTextStyle)
        self._optionTextStyle = Trackable(value: optionTextStyle)
        self._voteCountTextStyle = Trackable(value: voteCountTextStyle)
        self._checkboxStyle = Trackable(value: checkboxStyle)
        self._voterAvatarStyle = Trackable(value: voterAvatarStyle)
    }
    
    public init(
        reference: PollViewAppearance,
        progressBarBackground: UIColor? = nil,
        progressBarForeground: UIColor? = nil,
        questionTextStyle: LabelAppearance? = nil,
        pollTypeTextStyle: LabelAppearance? = nil,
        optionTextStyle: LabelAppearance? = nil,
        voteCountTextStyle: LabelAppearance? = nil,
        checkboxStyle: CheckboxStyle? = nil,
        voterAvatarStyle: AvatarStyle? = nil
    ) {
        self._progressBarBackground = Trackable(reference: reference, referencePath: \.progressBarBackground)
        self._progressBarForeground = Trackable(reference: reference, referencePath: \.progressBarForeground)
        self._questionTextStyle = Trackable(reference: reference, referencePath: \.questionTextStyle)
        self._pollTypeTextStyle = Trackable(reference: reference, referencePath: \.pollTypeTextStyle)
        self._optionTextStyle = Trackable(reference: reference, referencePath: \.optionTextStyle)
        self._voteCountTextStyle = Trackable(reference: reference, referencePath: \.voteCountTextStyle)
        self._checkboxStyle = Trackable(reference: reference, referencePath: \.checkboxStyle)
        self._voterAvatarStyle = Trackable(reference: reference, referencePath: \.voterAvatarStyle)

        if let progressBarBackground { self.progressBarBackground = progressBarBackground }
        if let progressBarForeground { self.progressBarForeground = progressBarForeground }
        if let questionTextStyle { self.questionTextStyle = questionTextStyle }
        if let pollTypeTextStyle { self.pollTypeTextStyle = pollTypeTextStyle }
        if let optionTextStyle { self.optionTextStyle = optionTextStyle }
        if let voteCountTextStyle { self.voteCountTextStyle = voteCountTextStyle }
        if let checkboxStyle { self.checkboxStyle = checkboxStyle }
        if let voterAvatarStyle { self.voterAvatarStyle = voterAvatarStyle }
    }
}

// MARK: - Supporting Types

public extension PollViewAppearance {
    
    struct CheckboxStyle: Equatable {
        public var size: CGFloat
        public var spacing: CGFloat
        public var selectedColor: UIColor
        public var unselectedColor: UIColor
        public var borderWidth: CGFloat
        public var cornerRadius: CGFloat
        
        public init(
            size: CGFloat,
            spacing: CGFloat,
            selectedColor: UIColor,
            unselectedColor: UIColor,
            borderWidth: CGFloat,
            cornerRadius: CGFloat
        ) {
            self.size = size
            self.spacing = spacing
            self.selectedColor = selectedColor
            self.unselectedColor = unselectedColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
        }
        
        public static func == (lhs: CheckboxStyle, rhs: CheckboxStyle) -> Bool {
            lhs.size == rhs.size &&
            lhs.spacing == rhs.spacing &&
            lhs.selectedColor == rhs.selectedColor &&
            lhs.unselectedColor == rhs.unselectedColor &&
            lhs.borderWidth == rhs.borderWidth &&
            lhs.cornerRadius == rhs.cornerRadius
        }
    }

    struct AvatarStyle: Equatable {
        public var size: CGFloat
        public var borderWidth: CGFloat
        public var spacing: CGFloat

        public init(size: CGFloat, borderWidth: CGFloat, spacing: CGFloat) {
            self.size = size
            self.borderWidth = borderWidth
            self.spacing = spacing
        }

        public static func == (lhs: AvatarStyle, rhs: AvatarStyle) -> Bool {
            lhs.size == rhs.size &&
            lhs.borderWidth == rhs.borderWidth &&
            lhs.spacing == rhs.spacing
        }
    }
}
