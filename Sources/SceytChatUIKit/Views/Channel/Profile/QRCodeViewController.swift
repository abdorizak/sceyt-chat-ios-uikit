//
//  QRCodeViewController.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

open class QRCodeViewController: ViewController {

    public var inviteLink: String = ""

    open lazy var qrCodeImageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        return $0.withoutAutoresizingMask
    }(UIImageView())

    open lazy var stackView: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        return $0.withoutAutoresizingMask
    }(UIStackView())

    open lazy var titleLabel: UILabel = {
        $0.textAlignment = .center
        return $0.withoutAutoresizingMask
    }(UILabel())

    open lazy var linkLabel: UILabel = {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0.withoutAutoresizingMask
    }(UILabel())

    open lazy var shareButton: UIButton = {
        $0.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return $0.withoutAutoresizingMask
    }(UIButton(type: .system))

    open override func setup() {
        super.setup()

        title = appearance.titleText
        titleLabel.text = appearance.titleText
        linkLabel.text = "Show or send this to anyone who wants to join this channel"
        shareButton.setTitle(appearance.shareButtonTitle, for: .normal)

        // Generate QR code
        if !inviteLink.isEmpty, let qrCodeImage = Components.imageBuilder.qrCode(
            from: inviteLink,
            size: appearance.qrCodeSize
        ) {
            qrCodeImageView.image = qrCodeImage
        }
    }

    open override func setupLayout() {
        super.setupLayout()

        view.addSubview(titleLabel)
        stackView.addArrangedSubview(qrCodeImageView)
        view.addSubview(stackView)
        view.addSubview(linkLabel)
        view.addSubview(shareButton)

        let padding = appearance.qrCodePadding
        let horizontalPadding: CGFloat = 16.0

        // Title label at top of view
        titleLabel.pin(to: view.safeAreaLayoutGuide, anchors: [.leading(horizontalPadding), .trailing(-horizontalPadding), .top(20)])
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        // Share button at bottom of view
        shareButton.pin(to: view.safeAreaLayoutGuide, anchors: [.leading(horizontalPadding), .trailing(-horizontalPadding), .bottom(-horizontalPadding)])
        shareButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        shareButton.setContentCompressionResistancePriority(.required, for: .vertical)

        // Link label above share button - always visible
        linkLabel.pin(to: view.safeAreaLayoutGuide, anchors: [.leading(horizontalPadding), .trailing(-horizontalPadding)])
        linkLabel.setContentHuggingPriority(.required, for: .vertical)
        linkLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        linkLabel.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -horizontalPadding).isActive = true

        // Stack view with configurable padding
        stackView.pin(to: view.safeAreaLayoutGuide, anchors: [
            .leading(padding.left),
            .trailing(-padding.right)
        ])
        stackView.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: horizontalPadding).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: linkLabel.topAnchor, constant: -horizontalPadding).isActive = true

        // Center stack view vertically with lower priority to allow flexibility
        let centerYConstraint = stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -horizontalPadding)
        centerYConstraint.priority = UILayoutPriority(750) // Lower than required
        centerYConstraint.isActive = true

        qrCodeImageView.contentMode = .scaleAspectFit
        // Ensure QR code doesn't become too large
        let maxSize = min(view.bounds.width - padding.left - padding.right, 200)
        qrCodeImageView.widthAnchor.constraint(lessThanOrEqualToConstant: maxSize).isActive = true
    }

    open override func setupAppearance() {
        super.setupAppearance()

        view.backgroundColor = appearance.backgroundColor

        // Apply QR code image view appearance
        qrCodeImageView.backgroundColor = appearance.qrCodeBackgroundColor

        // Apply title label appearance
        let titleAppearance = appearance.titleLabelAppearance
        titleLabel.font = titleAppearance.font
        titleLabel.textColor = titleAppearance.foregroundColor
        titleLabel.backgroundColor = titleAppearance.backgroundColor

        // Apply link label appearance
        let linkAppearance = appearance.linkLabelAppearance
        linkLabel.font = linkAppearance.font
        linkLabel.textColor = linkAppearance.foregroundColor
        linkLabel.backgroundColor = linkAppearance.backgroundColor

        // Apply share button appearance
        let buttonAppearance = appearance.shareButtonAppearance
        shareButton.setTitleColor(buttonAppearance.labelAppearance.foregroundColor, for: .normal)
        shareButton.backgroundColor = buttonAppearance.backgroundColor
        shareButton.layer.cornerRadius = buttonAppearance.cornerRadius
        shareButton.layer.cornerCurve = buttonAppearance.cornerCurve
        shareButton.titleLabel?.font = buttonAppearance.labelAppearance.font
        shareButton.tintColor = buttonAppearance.tintColor
    }

    @objc open func shareButtonTapped() {
        let activityViewController = UIActivityViewController(
            activityItems: [inviteLink],
            applicationActivities: nil
        )

        // For iPad popover presentation
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }

        present(activityViewController, animated: true)
    }
}
