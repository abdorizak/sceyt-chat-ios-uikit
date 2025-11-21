//
//  CreatePollViewController+AddOptionCell.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension CreatePollViewController {
    open class AddOptionCell: TableViewCell {

        open lazy var iconView = UIImageView()
            .withoutAutoresizingMask

        open lazy var titleLabel = UILabel()
            .withoutAutoresizingMask

        open var onTapped: (() -> Void)?

        open override func setup() {
            super.setup()

            iconView.contentMode = .scaleAspectFit
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            contentView.addGestureRecognizer(tapGesture)
        }

        @objc private func handleTap() {
            onTapped?()
        }

        open override func setupLayout() {
            super.setupLayout()

            contentView.addSubview(iconView)
            contentView.addSubview(titleLabel)

            iconView.pin(to: contentView, anchors: [.leading, .centerY])
            iconView.resize(anchors: [.height(24), .width(24)])

            titleLabel.pin(to: contentView, anchors: [.top(12), .bottom(-12)])
            titleLabel.leadingAnchor.pin(to: iconView.trailingAnchor, constant: 12)
            titleLabel.trailingAnchor.pin(to: contentView.trailingAnchor, constant: -16)

            contentView.heightAnchor.pin(greaterThanOrEqualToConstant: 56)
        }

        open override var safeAreaInsets: UIEdgeInsets {
            .init(top: 0, left: 2 * CreatePollViewController.Layouts.cellHorizontalPadding,
                  bottom: 0, right: 2 * CreatePollViewController.Layouts.cellHorizontalPadding)
        }

        open override func setupAppearance() {
            super.setupAppearance()

            backgroundColor = appearance.backgroundColor
            titleLabel.textColor = appearance.titleLabelAppearance.foregroundColor
            titleLabel.font = appearance.titleLabelAppearance.font
            iconView.tintColor = appearance.iconTintColor
        }
    }
}
