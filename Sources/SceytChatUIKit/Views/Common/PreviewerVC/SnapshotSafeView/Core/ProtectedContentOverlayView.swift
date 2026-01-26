//
//  ProtectedContentOverlayView.swift
//  SceytChatUIKit
//
//  Created by Abdirizak Hassan on 1/26/26.
//


import UIKit

open class ProtectedContentOverlayView: UIView {
    
    // MARK: - UI Components
    
    open lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    open lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    open lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Constraints
    
    private var iconHeightConstraint: NSLayoutConstraint?
    private var iconWidthConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayout()
        setupAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupLayout()
        setupAppearance()
    }
    
    // MARK: - Setup
    
    open func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    open func setupLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        let iconSize = Self.appearance.iconSize
        iconHeightConstraint = iconImageView.heightAnchor.constraint(equalToConstant: iconSize)
        iconWidthConstraint = iconImageView.widthAnchor.constraint(equalToConstant: iconSize)
        
        NSLayoutConstraint.activate([
            iconHeightConstraint!,
            iconWidthConstraint!,
            
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
        ])
    }
    
    open func setupAppearance() {
        let appearance = Self.appearance
        
        backgroundColor = appearance.backgroundColor
        
        // Icon
        iconImageView.image = appearance.icon
        iconImageView.tintColor = appearance.iconTintColor
        iconHeightConstraint?.constant = appearance.iconSize
        iconWidthConstraint?.constant = appearance.iconSize
        
        // Title
        titleLabel.text = appearance.titleText
        titleLabel.font = appearance.titleLabelAppearance.font
        titleLabel.textColor = appearance.titleLabelAppearance.foregroundColor
        
        // Message
        messageLabel.text = appearance.messageText
        messageLabel.font = appearance.messageLabelAppearance.font
        messageLabel.textColor = appearance.messageLabelAppearance.foregroundColor
    }
    
    // MARK: - Public Methods
    
    /// Updates the icon size dynamically.
    open func updateIconSize(_ size: CGFloat) {
        iconHeightConstraint?.constant = size
        iconWidthConstraint?.constant = size
    }
}
