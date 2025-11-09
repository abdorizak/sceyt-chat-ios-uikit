//
//  BottomActionViewAppearance.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 09.11.25.
//  Copyright © 2024 Sceyt LLC. All rights reserved.
//

import UIKit

public class BottomActionViewAppearance: AppearanceProviding {

    public var appearance: BottomActionViewAppearance {
        parentAppearance ?? Self.appearance
    }

    public var parentAppearance: BottomActionViewAppearance?

    public static var appearance = BottomActionViewAppearance(
        separatorColor: .border,
        buttonTextStyle: .init(
            foregroundColor: .accent,
            font: Fonts.semiBold.withSize(16.0)
        ),
        buttonDisabledTextStyle: .init(
            foregroundColor: DefaultColors.iconTertiary,
            font: Fonts.semiBold.withSize(16.0)
        )
    )

    // MARK: - Colors

    @Trackable<BottomActionViewAppearance, UIColor>
    public var separatorColor: UIColor

    // MARK: - Text Styles

    @Trackable<BottomActionViewAppearance, LabelAppearance>
    public var buttonTextStyle: LabelAppearance

    @Trackable<BottomActionViewAppearance, LabelAppearance>
    public var buttonDisabledTextStyle: LabelAppearance

    // MARK: - Initializers
    
    public init(
        separatorColor: UIColor,
        buttonTextStyle: LabelAppearance,
        buttonDisabledTextStyle: LabelAppearance
    ) {
        self._separatorColor = Trackable(value: separatorColor)
        self._buttonTextStyle = Trackable(value: buttonTextStyle)
        self._buttonDisabledTextStyle = Trackable(value: buttonDisabledTextStyle)
    }
    
    public init(
        reference: BottomActionViewAppearance,
        separatorColor: UIColor? = nil,
        buttonTextStyle: LabelAppearance? = nil,
        buttonDisabledTextStyle: LabelAppearance? = nil
    ) {
        self._separatorColor = Trackable(reference: reference, referencePath: \.separatorColor)
        self._buttonTextStyle = Trackable(reference: reference, referencePath: \.buttonTextStyle)
        self._buttonDisabledTextStyle = Trackable(reference: reference, referencePath: \.buttonDisabledTextStyle)

        if let separatorColor { self.separatorColor = separatorColor }
        if let buttonTextStyle { self.buttonTextStyle = buttonTextStyle }
        if let buttonDisabledTextStyle { self.buttonDisabledTextStyle = buttonDisabledTextStyle }
    }
}

