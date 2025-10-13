//
//  JoinGroupViewController.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit
import Combine
import SceytChat

open class JoinGroupViewController: ViewController {
    
    public var joinGroupViewModel: JoinGroupViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
    open lazy var router = Components.joinGroupRouter
        .init(rootViewController: self)
    
    open lazy var scrollView: UIScrollView = {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        return $0.withoutAutoresizingMask
    }(UIScrollView())
    
    open lazy var contentView: UIView = {
        return $0.withoutAutoresizingMask
    }(UIView())
    
    open lazy var stackView: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 12
        return $0.withoutAutoresizingMask
    }(UIStackView())
    
    open lazy var labelsStackView: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 2
        return $0.withoutAutoresizingMask
    }(UIStackView())
    
    open lazy var channelAvatarImageView: ImageView = {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.backgroundColor = .systemGray5
        return $0.withoutAutoresizingMask
    }(ImageView())
    
    open lazy var channelNameLabel: UILabel = {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0.withoutAutoresizingMask
    }(UILabel())
    
    open lazy var channelDescriptionLabel: UILabel = {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0.withoutAutoresizingMask
    }(UILabel())
    
    open lazy var joinButton: UIButton = {
        $0.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return $0.withoutAutoresizingMask
    }(UIButton(type: .system))
    
    open lazy var closeButton: UIButton = {
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return $0.withoutAutoresizingMask
    }(UIButton(type: .system))
    
    open override func setup() {
        super.setup()
        
        setupBindings()
        loadChannelInfo()
    }
    
    private func setupBindings() {
        // Handle loading state and channel availability
        Publishers.CombineLatest(
            joinGroupViewModel.$isLoading,
            joinGroupViewModel.$event.map { $0 != nil }
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isLoading, hasChannel in
            self?.joinButton.isHidden = isLoading || !hasChannel
        }
        .store(in: &subscriptions)
        
        // Handle joining state
        joinGroupViewModel.$isJoining
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isJoining in
                self?.updateJoinButtonState(isJoining: isJoining)
            }
            .store(in: &subscriptions)
        
        joinGroupViewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &subscriptions)
        
        // Handle view model events
        joinGroupViewModel.$event
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.onEvent(event)
            }
            .store(in: &subscriptions)
    }
    
    private func loadChannelInfo() {
        joinGroupViewModel.loadChannelInfo()
    }
    
    open override func setupLayout() {
        super.setupLayout()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        // Add labels to labels stack view
        labelsStackView.addArrangedSubview(channelNameLabel)
        labelsStackView.addArrangedSubview(channelDescriptionLabel)

        // Add subviews to main stack view
        stackView.addArrangedSubview(channelAvatarImageView)
        stackView.addArrangedSubview(labelsStackView)

        // Add join button and close button to main view
        view.addSubview(joinButton)
        view.addSubview(closeButton)

        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 33

        // Scroll view constraints
        scrollView.pin(to: view.safeAreaLayoutGuide, anchors: [.leading, .trailing, .top])

        // Content view constraints
        contentView.pin(to: scrollView, anchors: [.leading, .trailing, .top, .bottom])
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        // Stack view constraints
        stackView.pin(to: contentView, anchors: [
            .leading(horizontalPadding),
            .trailing(-horizontalPadding),
            .top(verticalPadding),
            .bottom(-verticalPadding)
        ])

        // Channel avatar constraints
        channelAvatarImageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        channelAvatarImageView.heightAnchor.constraint(equalToConstant: 90).isActive = true

        // Join button at bottom of view
        joinButton.pin(to: view.safeAreaLayoutGuide, anchors: [.leading(horizontalPadding), .trailing(-horizontalPadding), .bottom(-horizontalPadding)])
        joinButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Scroll view bottom constraint (above join button)
        scrollView.bottomAnchor.constraint(equalTo: joinButton.topAnchor, constant: -horizontalPadding).isActive = true

        // Close button constraints
        closeButton.pin(to: view.safeAreaLayoutGuide, anchors: [.top(12), .trailing(-12)])
        closeButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = appearance.backgroundColor
        
        // Channel avatar appearance
        channelAvatarImageView.layer.cornerRadius = 45 // Half of 120 for circular avatar
        channelAvatarImageView.layer.borderWidth = appearance.avatarBorderWidth
        channelAvatarImageView.layer.borderColor = appearance.avatarBorderColor?.cgColor
        
        // Channel name label appearance
        let nameAppearance = appearance.channelNameLabelAppearance
        channelNameLabel.font = nameAppearance.font
        channelNameLabel.textColor = nameAppearance.foregroundColor
        channelNameLabel.backgroundColor = nameAppearance.backgroundColor
        
        // Channel description label appearance
        let descriptionAppearance = appearance.channelDescriptionLabelAppearance
        channelDescriptionLabel.font = descriptionAppearance.font
        channelDescriptionLabel.textColor = descriptionAppearance.foregroundColor
        channelDescriptionLabel.backgroundColor = descriptionAppearance.backgroundColor
        
        // Join button appearance
        let buttonAppearance = appearance.joinButtonAppearance
        joinButton.setTitleColor(buttonAppearance.labelAppearance.foregroundColor, for: .normal)
        joinButton.backgroundColor = buttonAppearance.backgroundColor
        joinButton.layer.cornerRadius = buttonAppearance.cornerRadius
        joinButton.layer.cornerCurve = buttonAppearance.cornerCurve
        joinButton.titleLabel?.font = buttonAppearance.labelAppearance.font
        joinButton.tintColor = buttonAppearance.tintColor
        
        // Close button appearance
        closeButton.setImage(.closeIcon, for: .normal)
        closeButton.tintColor = appearance.closeButtonTintColor
        closeButton.backgroundColor = appearance.closeButtonBackgroundColor
        closeButton.layer.cornerRadius = 14
    }
    
    private func updateJoinButtonState(isJoining: Bool) {
        if isJoining {
            joinButton.setTitle(appearance.joiningButtonTitle, for: .normal)
            joinButton.isEnabled = false
            joinButton.alpha = 0.6
        } else {
            joinButton.setTitle(appearance.joinButtonTitle, for: .normal)
            joinButton.isEnabled = true
            joinButton.alpha = 1.0
        }
    }
    
    private func updateChannelInfo() {
        guard let channel = joinGroupViewModel.channel else { return }
        
        // Set channel name
        channelNameLabel.text = channel.subject
        
        // Set channel description if available, otherwise use default
        if let description = channel.metadata, !description.isEmpty {
            channelDescriptionLabel.text = description
            channelDescriptionLabel.isHidden = false
        } else {
            channelDescriptionLabel.text = appearance.defaultChannelDescription
            channelDescriptionLabel.isHidden = false
        }
        
        // Load and set channel avatar
        loadChannelAvatar(channel: channel)
    }
    
    private func loadChannelAvatar(channel: ChatChannel) {
        // Use the appearance avatar renderer to load the channel avatar
        appearance.avatarRenderer.render(
            channel,
            with: appearance.avatarAppearance,
            into: channelAvatarImageView,
            size: CGSize(width: 90, height: 90)
        )
    }
    
    // MARK: Actions
    
    @objc open func joinButtonTapped() {
        joinGroupViewModel.joinChannel()
    }
    
    @objc open func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: Error Handling
    
    private func handleError(_ error: Error) {
        let cancelAction = SheetAction.init(title: L10n.Alert.Button.cancel, icon: nil, style: .cancel) { [weak self] in
            if self?.joinGroupViewModel.shouldDismissOnError == true {
                self?.dismiss(animated: true)
            }
        }
        showAlert(title: L10n.Alert.Error.title, message: error.localizedDescription, actions: [cancelAction], preferredActionIndex: 0, completion: nil)
    }

    // MARK: ViewModel Events
    
    open func onEvent(_ event: JoinGroupViewModel.Event) {
        switch event {
        case .channelLoaded(let channel):
            updateChannelInfo()
        case .joinedChannel(let channel):
            router.showChannel(channel)
        }
    }
}
