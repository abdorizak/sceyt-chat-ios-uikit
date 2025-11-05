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
        dividerColor: .white,
        progressBarBackground: UIColor.systemBlue,
        progressBarForeground: UIColor.systemGray5,
        questionTextStyle: .init(
            foregroundColor: .label,
            font: Fonts.semiBold.withSize(16)
        ),
        pollTypeTextStyle: .init(
            foregroundColor: .secondaryLabel,
            font: Fonts.regular.withSize(13)
        ),
        viewResultsTextStyle: .init(
            foregroundColor: .accent,
            font: Fonts.semiBold.withSize(14)
        ),
        viewResultsDisabledTextStyle: .init(
            foregroundColor: DefaultColors.iconTertiary,
            font: Fonts.semiBold.withSize(14)
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
            borderWidth: 2,
            borderColor: .systemBackground,
            spacing: -8
        ),
        questionBottomSpacing: 16.0,
        optionSpacing: 20.0,
        optionMinHeight: 40,
        progressBarHeight: 6,
        progressBarCornerRadius: 2,
        containerCornerRadius: 12,
        containerInsets: UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12),
        votersContainerWidth: 50.0
    )
    
    // MARK: - Colors
    
    @Trackable<PollViewAppearance, UIColor>
    public var dividerColor: UIColor
    
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
    public var viewResultsTextStyle: LabelAppearance
    
    @Trackable<PollViewAppearance, LabelAppearance>
    public var viewResultsDisabledTextStyle: LabelAppearance
    
    @Trackable<PollViewAppearance, LabelAppearance>
    public var optionTextStyle: LabelAppearance
    
    @Trackable<PollViewAppearance, LabelAppearance>
    public var voteCountTextStyle: LabelAppearance
    
    // MARK: - Component Styles
    
    @Trackable<PollViewAppearance, CheckboxStyle>
    public var checkboxStyle: CheckboxStyle
    
    @Trackable<PollViewAppearance, AvatarStyle>
    public var voterAvatarStyle: AvatarStyle
    
    // MARK: - Spacing & Sizing
    
    @Trackable<PollViewAppearance, CGFloat>
    public var questionBottomSpacing: CGFloat
    
    @Trackable<PollViewAppearance, CGFloat>
    public var optionSpacing: CGFloat
    
    @Trackable<PollViewAppearance, CGFloat>
    public var optionMinHeight: CGFloat
    
    @Trackable<PollViewAppearance, CGFloat>
    public var progressBarHeight: CGFloat
    
    @Trackable<PollViewAppearance, CGFloat>
    public var progressBarCornerRadius: CGFloat
    
    @Trackable<PollViewAppearance, CGFloat>
    public var containerCornerRadius: CGFloat
    
    @Trackable<PollViewAppearance, UIEdgeInsets>
    public var containerInsets: UIEdgeInsets

    @Trackable<PollViewAppearance, CGFloat>
    public var votersContainerWidth: CGFloat
    
    // MARK: - Initializers
    
    public init(
        dividerColor: UIColor,
        progressBarBackground: UIColor,
        progressBarForeground: UIColor,
        questionTextStyle: LabelAppearance,
        pollTypeTextStyle: LabelAppearance,
        viewResultsTextStyle: LabelAppearance,
        viewResultsDisabledTextStyle: LabelAppearance,
        optionTextStyle: LabelAppearance,
        voteCountTextStyle: LabelAppearance,
        checkboxStyle: CheckboxStyle,
        voterAvatarStyle: AvatarStyle,
        questionBottomSpacing: CGFloat,
        optionSpacing: CGFloat,
        optionMinHeight: CGFloat,
        progressBarHeight: CGFloat,
        progressBarCornerRadius: CGFloat,
        containerCornerRadius: CGFloat,
        containerInsets: UIEdgeInsets,
        votersContainerWidth: CGFloat
    ) {
        self._dividerColor = Trackable(value: dividerColor)
        self._progressBarBackground = Trackable(value: progressBarBackground)
        self._progressBarForeground = Trackable(value: progressBarForeground)
        self._questionTextStyle = Trackable(value: questionTextStyle)
        self._pollTypeTextStyle = Trackable(value: pollTypeTextStyle)
        self._viewResultsTextStyle = Trackable(value: viewResultsTextStyle)
        self._viewResultsDisabledTextStyle = Trackable(value: viewResultsDisabledTextStyle)
        self._optionTextStyle = Trackable(value: optionTextStyle)
        self._voteCountTextStyle = Trackable(value: voteCountTextStyle)
        self._checkboxStyle = Trackable(value: checkboxStyle)
        self._voterAvatarStyle = Trackable(value: voterAvatarStyle)
        self._questionBottomSpacing = Trackable(value: questionBottomSpacing)
        self._optionSpacing = Trackable(value: optionSpacing)
        self._optionMinHeight = Trackable(value: optionMinHeight)
        self._progressBarHeight = Trackable(value: progressBarHeight)
        self._progressBarCornerRadius = Trackable(value: progressBarCornerRadius)
        self._containerCornerRadius = Trackable(value: containerCornerRadius)
        self._containerInsets = Trackable(value: containerInsets)
        self._votersContainerWidth = Trackable(value: votersContainerWidth)
    }
    
    public init(
        reference: PollViewAppearance,
        dividerColor: UIColor? = nil,
        progressBarBackground: UIColor? = nil,
        progressBarForeground: UIColor? = nil,
        questionTextStyle: LabelAppearance? = nil,
        pollTypeTextStyle: LabelAppearance? = nil,
        viewResultsTextStyle: LabelAppearance? = nil,
        viewResultsDisabledTextStyle: LabelAppearance? = nil,
        optionTextStyle: LabelAppearance? = nil,
        voteCountTextStyle: LabelAppearance? = nil,
        checkboxStyle: CheckboxStyle? = nil,
        voterAvatarStyle: AvatarStyle? = nil,
        questionBottomSpacing: CGFloat? = nil,
        optionSpacing: CGFloat? = nil,
        optionMinHeight: CGFloat? = nil,
        progressBarHeight: CGFloat? = nil,
        progressBarCornerRadius: CGFloat? = nil,
        containerCornerRadius: CGFloat? = nil,
        containerInsets: UIEdgeInsets? = nil,
        votersContainerWidth: CGFloat? = nil
    ) {
        self._dividerColor = Trackable(reference: reference, referencePath: \.dividerColor)
        self._progressBarBackground = Trackable(reference: reference, referencePath: \.progressBarBackground)
        self._progressBarForeground = Trackable(reference: reference, referencePath: \.progressBarForeground)
        self._questionTextStyle = Trackable(reference: reference, referencePath: \.questionTextStyle)
        self._pollTypeTextStyle = Trackable(reference: reference, referencePath: \.pollTypeTextStyle)
        self._viewResultsTextStyle = Trackable(reference: reference, referencePath: \.viewResultsTextStyle)
        self._viewResultsDisabledTextStyle = Trackable(reference: reference, referencePath: \.viewResultsDisabledTextStyle)
        self._optionTextStyle = Trackable(reference: reference, referencePath: \.optionTextStyle)
        self._voteCountTextStyle = Trackable(reference: reference, referencePath: \.voteCountTextStyle)
        self._checkboxStyle = Trackable(reference: reference, referencePath: \.checkboxStyle)
        self._voterAvatarStyle = Trackable(reference: reference, referencePath: \.voterAvatarStyle)
        self._questionBottomSpacing = Trackable(reference: reference, referencePath: \.questionBottomSpacing)
        self._optionSpacing = Trackable(reference: reference, referencePath: \.optionSpacing)
        self._optionMinHeight = Trackable(reference: reference, referencePath: \.optionMinHeight)
        self._progressBarHeight = Trackable(reference: reference, referencePath: \.progressBarHeight)
        self._progressBarCornerRadius = Trackable(reference: reference, referencePath: \.progressBarCornerRadius)
        self._containerCornerRadius = Trackable(reference: reference, referencePath: \.containerCornerRadius)
        self._containerInsets = Trackable(reference: reference, referencePath: \.containerInsets)
        self._votersContainerWidth = Trackable(reference: reference, referencePath: \.votersContainerWidth)
        
        if let dividerColor { self.dividerColor = dividerColor }
        if let progressBarBackground { self.progressBarBackground = progressBarBackground }
        if let progressBarForeground { self.progressBarForeground = progressBarForeground }
        if let questionTextStyle { self.questionTextStyle = questionTextStyle }
        if let pollTypeTextStyle { self.pollTypeTextStyle = pollTypeTextStyle }
        if let viewResultsTextStyle { self.viewResultsTextStyle = viewResultsTextStyle }
        if let viewResultsDisabledTextStyle { self.viewResultsDisabledTextStyle = viewResultsDisabledTextStyle }
        if let optionTextStyle { self.optionTextStyle = optionTextStyle }
        if let voteCountTextStyle { self.voteCountTextStyle = voteCountTextStyle }
        if let checkboxStyle { self.checkboxStyle = checkboxStyle }
        if let voterAvatarStyle { self.voterAvatarStyle = voterAvatarStyle }
        if let questionBottomSpacing { self.questionBottomSpacing = questionBottomSpacing }
        if let optionSpacing { self.optionSpacing = optionSpacing }
        if let optionMinHeight { self.optionMinHeight = optionMinHeight }
        if let progressBarHeight { self.progressBarHeight = progressBarHeight }
        if let progressBarCornerRadius { self.progressBarCornerRadius = progressBarCornerRadius }
        if let containerCornerRadius { self.containerCornerRadius = containerCornerRadius }
        if let containerInsets { self.containerInsets = containerInsets }
        if let votersContainerWidth { self.votersContainerWidth = votersContainerWidth }
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
        public var borderColor: UIColor
        public var spacing: CGFloat
        
        public init(
            size: CGFloat,
            borderWidth: CGFloat,
            borderColor: UIColor,
            spacing: CGFloat
        ) {
            self.size = size
            self.borderWidth = borderWidth
            self.borderColor = borderColor
            self.spacing = spacing
        }
        
        public static func == (lhs: AvatarStyle, rhs: AvatarStyle) -> Bool {
            lhs.size == rhs.size &&
            lhs.borderWidth == rhs.borderWidth &&
            lhs.borderColor == rhs.borderColor &&
            lhs.spacing == rhs.spacing
        }
    }
}

