//
//  ProtectedContentOverlayView+Appearance.swift
//  SceytChatUIKit
//
//  Created by Abdirizak Hassan on 1/26/26.
//

import UIKit

extension ProtectedContentOverlayView: AppearanceProviding {
    public static var appearance = Appearance(
        backgroundColor: .background,
        icon: UIImage(systemName: "eye.slash.fill"),
        iconTintColor: .secondaryText,
        iconSize: 60,
        titleLabelAppearance: LabelAppearance(
            foregroundColor: .primaryText,
            font: .boldSystemFont(ofSize: 20)
        ),
        messageLabelAppearance: LabelAppearance(
            foregroundColor: .secondaryText,
            font: .systemFont(ofSize: 14)
        ),
        titleText: L10n.ViewOnce.Screenshot.Alert.title,
        messageText: L10n.ViewOnce.Screenshot.Alert.message
    )
    
    public struct Appearance {
        @Trackable<Appearance, UIColor>
        public var backgroundColor: UIColor
        
        @Trackable<Appearance, UIImage?>
        public var icon: UIImage?
        
        @Trackable<Appearance, UIColor>
        public var iconTintColor: UIColor
        
        @Trackable<Appearance, CGFloat>
        public var iconSize: CGFloat
        
        @Trackable<Appearance, LabelAppearance>
        public var titleLabelAppearance: LabelAppearance
        
        @Trackable<Appearance, LabelAppearance>
        public var messageLabelAppearance: LabelAppearance
        
        @Trackable<Appearance, String>
        public var titleText: String
        
        @Trackable<Appearance, String>
        public var messageText: String
        
        public init(
            backgroundColor: UIColor,
            icon: UIImage?,
            iconTintColor: UIColor,
            iconSize: CGFloat,
            titleLabelAppearance: LabelAppearance,
            messageLabelAppearance: LabelAppearance,
            titleText: String,
            messageText: String
        ) {
            self._backgroundColor = Trackable(value: backgroundColor)
            self._icon = Trackable(value: icon)
            self._iconTintColor = Trackable(value: iconTintColor)
            self._iconSize = Trackable(value: iconSize)
            self._titleLabelAppearance = Trackable(value: titleLabelAppearance)
            self._messageLabelAppearance = Trackable(value: messageLabelAppearance)
            self._titleText = Trackable(value: titleText)
            self._messageText = Trackable(value: messageText)
        }
        
        public init(
            reference: ProtectedContentOverlayView.Appearance,
            backgroundColor: UIColor? = nil,
            icon: UIImage? = nil,
            iconTintColor: UIColor? = nil,
            iconSize: CGFloat? = nil,
            titleLabelAppearance: LabelAppearance? = nil,
            messageLabelAppearance: LabelAppearance? = nil,
            titleText: String? = nil,
            messageText: String? = nil
        ) {
            self._backgroundColor = Trackable(reference: reference, referencePath: \.backgroundColor)
            self._icon = Trackable(reference: reference, referencePath: \.icon)
            self._iconTintColor = Trackable(reference: reference, referencePath: \.iconTintColor)
            self._iconSize = Trackable(reference: reference, referencePath: \.iconSize)
            self._titleLabelAppearance = Trackable(reference: reference, referencePath: \.titleLabelAppearance)
            self._messageLabelAppearance = Trackable(reference: reference, referencePath: \.messageLabelAppearance)
            self._titleText = Trackable(reference: reference, referencePath: \.titleText)
            self._messageText = Trackable(reference: reference, referencePath: \.messageText)
            
            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let icon {
                self.icon = icon
            }
            if let iconTintColor {
                self.iconTintColor = iconTintColor
            }
            if let iconSize {
                self.iconSize = iconSize
            }
            if let titleLabelAppearance {
                self.titleLabelAppearance = titleLabelAppearance
            }
            if let messageLabelAppearance {
                self.messageLabelAppearance = messageLabelAppearance
            }
            if let titleText {
                self.titleText = titleText
            }
            if let messageText {
                self.messageText = messageText
            }
        }
    }
}
