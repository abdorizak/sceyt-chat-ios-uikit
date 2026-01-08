//
//  MediaPreviewerAudioViewController.swift
//  SceytChatUIKit
//
//  Created by Claude Code
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import AVFoundation
import SceytChat
import UIKit

open class MediaPreviewerAudioViewController: MediaPreviewerViewController {
    // MessageCell to display audio attachment
    private var messageCell: MessageCell!
    private var layoutModel: MessageLayoutModel!

    deinit {
        logger.debug("[MediaPreviewerAudioViewController] deinit")
    }

    override open func setup() {
        super.setup()

        viewModel.$event
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] event in
                self?.onEvent(event)
            }.store(in: &subscriptions)
    }

    override open func setupAppearance() {
        super.setupAppearance()

        playerControlView.isHidden = true
        playPauseButton.isHidden = true
        view.backgroundColor = appearance.backgroundColor
    }

    override open func setupLayout() {
        super.setupLayout()
    }

    override open func setupDone() {
        super.setupDone()
        bindPreviewItem()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Post notification for view_once messages
        if viewOnce {
            let messageId = viewModel.previewItem.attachment.messageId
            NotificationCenter.default.post(
                name: .didOpenViewOnceMessage,
                object: nil,
                userInfo: ["messageId": messageId]
            )
        }

        // Update carousel title/subtitle
        var title = ""
        if let user = viewModel.previewItem.attachment.user {
            title = appearance.userNameFormatter.format(user)
        }
        carouselViewController?.titleLabel.text = title
        carouselViewController?.subtitleLabel.text = appearance.mediaDateFormatter.format(viewModel.previewItem.attachment.createdAt)
    }

    open override func onEvent(_ event: PreviewerViewModel.Event) {
        switch event {
        case .didUpdateItem:
            bindPreviewItem()
        default:
            return
        }
    }

    open override func bindPreviewItem() {
        switch viewModel.previewItem {
        case let .attachment(attachment):
            guard attachment.type == "voice" else { return }

            // Fetch the message and channel from database using attachment's messageId
            guard let (message, channel): (ChatMessage, ChatChannel) = try? DataProvider.database.read({ context in
                guard let messageDTO = MessageDTO.fetch(id: attachment.messageId, context: context),
                      let channelDTO = ChannelDTO.fetch(id: ChannelId(messageDTO.channelId), context: context) else {
                    return nil
                }
                return (messageDTO.convert(), channelDTO.convert())
            }).get() else {
                logger.error("Could not fetch message or channel for attachment \(attachment.id)")
                return
            }

            // Create a MessageLayoutModel for the audio attachment
            layoutModel = Components.messageLayoutModel.init(
                channel: channel,
                message: message,
                appearance: Components.messageCell.appearance
            )

            // Calculate the measure size for the layout
            let measuredSize = layoutModel.measure()

            // Create and configure MessageCell
            if message.incoming {
                messageCell = ChannelViewController.IncomingMessageCell.init()
            } else {
                messageCell = ChannelViewController.OutgoingMessageCell.init()
            }
            

            view.addSubview(messageCell)
            messageCell.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                messageCell.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                messageCell.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                messageCell.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
                messageCell.heightAnchor.constraint(equalToConstant: measuredSize.height)
            ])

            messageCell.data = layoutModel

            // Force layout update
            messageCell.setNeedsLayout()
            messageCell.layoutIfNeeded()
        }
    }
}
