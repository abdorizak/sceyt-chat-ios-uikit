//
//  MessageCell+BottomActionView.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 09.11.25.
//

import UIKit

extension MessageCell {

    open class BottomActionView: View, MessageCellMeasurable {
 
        open lazy var appearance: BottomActionViewAppearance = Components.messageCell.appearance.bottomActionViewAppearance {
            didSet {
                setupAppearance()
            }
        }

        open lazy var separatorView = UIView()
            .withoutAutoresizingMask
        open lazy var actionButton = UIButton(type: .system)
            .withoutAutoresizingMask
        
        open var onAction: (() -> Void)?
        
        open var buttonText: String? {
            didSet {
                actionButton.setTitle(buttonText, for: .normal)
            }
        }

        override open func setup() {
            super.setup()

            actionButton.contentEdgeInsets.top = 13.0
            actionButton.contentEdgeInsets.bottom = 13.0
            actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        }
        
        override open func setupLayout() {
            super.setupLayout()
            
            addSubview(separatorView)
            addSubview(actionButton)

            separatorView.pin(to: self, anchors: [.leading, .trailing, .top])
            separatorView.resize(anchors: [.height(1.0)])

            actionButton.topAnchor.pin(to: separatorView.bottomAnchor)
            actionButton.pin(to: self, anchors: [.leading, .trailing, .bottom])
        }

        override open func setupAppearance() {
            super.setupAppearance()

            backgroundColor = .clear
            separatorView.backgroundColor = appearance.separatorColor

            actionButton.setTitleColor(appearance.buttonTextStyle.foregroundColor, for: .normal)
            actionButton.setTitleColor(appearance.buttonDisabledTextStyle.foregroundColor, for: .disabled)
            actionButton.titleLabel?.font = appearance.buttonTextStyle.font
        }

        open var isEnabled: Bool = true {
            didSet {
                actionButton.isEnabled = isEnabled
            }
        }

        @objc func didTapActionButton() {
            onAction?()
        }

        open class func measure(
            model: MessageLayoutModel,
            appearance: MessageCell.Appearance
        ) -> CGSize {
            let separatorHeight: CGFloat = 1.0
            let buttonTopInset: CGFloat = 13.0
            let buttonBottomInset: CGFloat = 13.0

            let font = appearance.bottomActionViewAppearance.buttonTextStyle.font
            let totalHeight = separatorHeight + buttonTopInset + ceil(font.pointSize) + buttonBottomInset
            return CGSize(width: Components.messageLayoutModel.defaults.messageWidth, height: totalHeight)
        }
    }
}
