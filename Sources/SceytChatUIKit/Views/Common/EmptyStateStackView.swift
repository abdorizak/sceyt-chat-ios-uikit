//
//  EmptyStateStackView.swift
//  SceytChatUIKit
//
//  Created by Sceyt on 13.12.2024.
//  Copyright © 2024 Sceyt LLC. All rights reserved.
//

import UIKit

open class EmptyStateStackView: UIStackView {

    open lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    open lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    open var icon: UIImage? {
        didSet {
            iconView.image = icon
            iconView.isHidden = icon == nil
        }
    }

    open var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.isHidden = title == nil || title!.isEmpty
        }
    }

    open var message: String? {
        didSet {
            messageLabel.text = message
            messageLabel.isHidden = message == nil || message!.isEmpty
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupAppearance()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupAppearance()
    }

    open func setup() {
        axis = .vertical
        alignment = .center
        distribution = .fill
        spacing = 12
        translatesAutoresizingMaskIntoConstraints = false

        addArrangedSubview(iconView)
        addArrangedSubview(titleLabel)
        addArrangedSubview(messageLabel)

        setCustomSpacing(12, after: iconView)
        setCustomSpacing(8, after: titleLabel)
    }

    open func setupAppearance() {
        icon = appearance.icon
        title = appearance.title
        message = appearance.message

        if let titleAppearance = appearance.titleLabelAppearance {
            titleLabel.font = titleAppearance.font
            titleLabel.textColor = titleAppearance.foregroundColor
        }

        if let messageAppearance = appearance.messageLabelAppearance {
            messageLabel.font = messageAppearance.font
            messageLabel.textColor = messageAppearance.foregroundColor
        }
    }

    open func configure(icon: UIImage? = nil, title: String?, message: String? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
    }
}
