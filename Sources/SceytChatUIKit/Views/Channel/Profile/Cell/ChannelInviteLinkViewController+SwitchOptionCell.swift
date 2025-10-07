//
//  ChannelInviteLinkViewController+SwitchOptionCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension ChannelInviteLinkViewController {
    open class SwitchOptionCell: TableViewCell {

        open lazy var titleLabel = UILabel()
            .withoutAutoresizingMask

        open lazy var switchControl = UISwitch()
            .withoutAutoresizingMask

        open lazy var separatorView = UIView()
            .withoutAutoresizingMask

        open var onSwitchChanged: ((Bool) -> Void)?

        open override func setup() {
            super.setup()

            switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        }

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(titleLabel)
            contentView.addSubview(switchControl)
            contentView.addSubview(separatorView)

            titleLabel.pin(to: contentView, anchors: [.leading, .top(12), .bottom(-12)])
            titleLabel.trailingAnchor.pin(to: switchControl.leadingAnchor, constant: -8)

            switchControl.pin(to: contentView, anchors: [.trailing, .centerY])

            separatorView.pin(to: contentView, anchors: [.leading, .trailing, .bottom])
            separatorView.heightAnchor.pin(constant: 1)

            contentView.heightAnchor.pin(greaterThanOrEqualToConstant: 56)
        }

        open override var safeAreaInsets: UIEdgeInsets {
            .init(top: 0, left: 2 * ChannelInviteLinkViewController.Layouts.cellHorizontalPadding,
                  bottom: 0, right: 2 * ChannelInviteLinkViewController.Layouts.cellHorizontalPadding)
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            titleLabel.textColor = appearance.titleLabelAppearance.foregroundColor
            titleLabel.font = appearance.titleLabelAppearance.font
            switchControl.onTintColor = appearance.switchTintColor
            separatorView.backgroundColor = appearance.separatorColor
        }

        @objc open func switchValueChanged() {
            onSwitchChanged?(switchControl.isOn)
        }
    }
}
