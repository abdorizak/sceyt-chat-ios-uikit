//
//  MessageCell+AttachmentStackView.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 29.09.22.
//  Copyright © 2022 Sceyt LLC. All rights reserved.
//

import SceytChat
import UIKit

extension MessageCell {
    open class AttachmentStackView: View {
        
        public lazy var appearance = Components.messageCell.appearance {
            didSet {
                setupAppearance()
            }
        }
        
        open var onAction: ((Action) -> Void)?
        
        open private(set) var attachments = [Attachment]()
        
        private var isConfigured = false
        
        override open func willMove(toSuperview newSuperview: UIView?) {
            super.willMove(toSuperview: newSuperview)
            guard !isConfigured, newSuperview != nil else { return }
            setupLayout()
            setupDone()
            isConfigured = true
        }
        
        open override func setup() {
            super.setup()
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            addGestureRecognizer(tap)
        }
        
        open override func setupAppearance() {
            super.setupAppearance()
//            alignment = .center
//            distribution = .fillProportionally
//            axis = .vertical
//            spacing = 4
        }
        
        open func addImageView(layout: MessageLayoutModel.AttachmentLayout) -> AttachmentImageView {
            let v = Components.messageCellAttachmentImageView.init()
                .withoutAutoresizingMask
            v.appearance = appearance
            addSubview(v)
            v.pin(to: self)
            v.heightAnchor.pin(constant: layout.thumbnailSize.height)
            v.widthAnchor.pin(to: widthAnchor)
            v.pauseButton.addTarget(self, action: #selector(pauseAction(_:)), for: .touchUpInside)
            return v
        }
        
        open func addVideoView(layout: MessageLayoutModel.AttachmentLayout) -> AttachmentVideoView {
            let v = Components.messageCellAttachmentVideoView.init()
                .withoutAutoresizingMask
            v.appearance = appearance
            addSubview(v)
            v.pin(to: self)
            v.heightAnchor.pin(constant: layout.thumbnailSize.height)
            v.widthAnchor.pin(to: widthAnchor)
            v.pauseButton.addTarget(self, action: #selector(pauseAction(_:)), for: .touchUpInside)
            return v
        }
        
        open func addFileView(layout: MessageLayoutModel.AttachmentLayout) -> AttachmentFileView {
            let v = Components.messageCellAttachmentFileView.init()
                .withoutAutoresizingMask
            v.appearance = appearance
            addSubview(v)
            v.pin(to: self)
            v.heightAnchor.pin(constant: layout.thumbnailSize.height)
            v.widthAnchor.pin(to: widthAnchor)
            v.pauseButton.addTarget(self, action: #selector(pauseAction(_:)), for: .touchUpInside)
            return v
        }
        
        open func addAudioView(layout: MessageLayoutModel.AttachmentLayout) -> AttachmentAudioView {
            let v = Components.messageCellAttachmentAudioView.init()
                .withoutAutoresizingMask
            v.appearance = appearance
            addSubview(v)
            v.pin(to: self)
            v.heightAnchor.pin(constant: layout.thumbnailSize.height)
            v.widthAnchor.pin(to: widthAnchor)
            v.playPauseButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapPlay)))
            v.pauseButton.addTarget(self, action: #selector(pauseAction(_:)), for: .touchUpInside)
            return v
        }

        open var previewer: (() -> AttachmentPreviewDataSource?)?
        
        open var data: MessageLayoutModel! {
            didSet {
                guard let data = data,
                      !data.attachments.isEmpty
                else {
                    subviews.forEach {
                        $0.removeFromSuperview()
                    }
                    return
                }
                subviews.forEach {
                    $0.removeFromSuperview()
                }
                addAttachmentViews(layouts: data.attachments)
            }
        }
        
        private func addAttachmentViews(layouts: [MessageLayoutModel.AttachmentLayout]) {
            layouts.forEach { layout in
                var av: AttachmentView?
                switch layout.type {
                case .image:
                    av = addImageView(layout: layout)
                case .video:
                    av = addVideoView(layout: layout)
                case .voice:
                    av = addAudioView(layout: layout)
                default:
                    av = addFileView(layout: layout)
                }
                av?.previewer = { [weak self] in
                    self?.previewer?()
                }
                guard let av else { return }
                av.data = layout
                av.setProgressHandler()
                switch layout.transferStatus {
                case .pending, .uploading, .downloading:
                    if let progress = fileProvider.currentProgressPercent(message: data.message, attachment: layout.attachment) {
                        av.setProgress(.init(message: data.message, attachment: layout.attachment, progress: progress))
                    } else {
                        av.setProgress(0.0001)
                    }
                case .pauseUploading, .failedUploading:
                    break
                case .pauseDownloading, .failedDownloading:
                    break
                case .done:
                    av.setProgress(0)
                }
            }
        }
        
        private func openPreview(sourceView: UIImageView) {
            // Create preview item directly from the audio attachment
            guard let attachment = self.data.message.attachments?.first else {
                return
            }
            let previewItem = PreviewItem.attachment(attachment)

            // Create the media previewer carousel
            let imageCarousel = Components.mediaPreviewerCarouselViewController.init(
                sourceView: sourceView,
                previewDataSource: SingleItemPreviewDataSource(item: previewItem),
                initialIndex: 0,
                viewOnce: true,
                messageText: nil)

            // Present the previewer
            if let viewController = window?.rootViewController {
                UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
                let presentFrom = viewController.presentedViewController ?? viewController
                presentFrom.present(Components.mediaPreviewerNavigationController.init(imageCarousel), animated: true)
            }
        }
        
        @objc
        private func onTapPlay() {
            guard let audioView = (subviews.first(where: { $0 is AttachmentAudioView }) as? AttachmentAudioView) else { return }

            guard previewer?()?.canShowPreviewer() ?? true else { return }

            // Check if we're already inside a previewer
            let isInsidePreviewer = sequence(first: window?.rootViewController, next: { $0?.presentedViewController })
                .contains { $0 is MediaPreviewerNavigationController }

            // Check if this is a view_once audio message
            let isViewOnce = audioView.data?.ownerMessage?.isViewOnceMessage ?? false

            if isViewOnce && !isInsidePreviewer {
                // Open the previewer for view_once audio (only if not already in previewer)
                guard let attachment = audioView.data?.attachment,
                      attachment.status == .done // Only open if downloaded
                else { return }

                // Trigger the openedViewOnce action
                onAction?(.openedViewOnce(attachment))

                self.openPreview(sourceView: UIImageView())
            } else {
                // Regular playback for non-view_once audio or when already in previewer
                audioView.play(onPlayed: { url in
                    onAction?(.playedAudio(url))
                })
            }
        }
        
        @objc
        private func tapAction(_ sender: UITapGestureRecognizer) {
            let point = sender.location(in: self)
            if let index = subviews.firstIndex(where: { $0.frame.contains(point) }) {
                // Check if we're already inside a previewer
                let isInsidePreviewer = sequence(first: window?.rootViewController, next: { $0?.presentedViewController })
                    .contains { $0 is MediaPreviewerNavigationController }

                // Check if tapped view is an audio attachment with view_once message
                if let audioView = subviews[index] as? AttachmentAudioView,
                   let attachment = audioView.data?.attachment,
                   audioView.data?.ownerMessage?.isViewOnceMessage == true,
                   attachment.status == .done,
                   !isInsidePreviewer,
                   previewer?()?.canShowPreviewer() ?? true {
                    // Handle view_once audio: open previewer (only if not already in previewer)
                    onAction?(.openedViewOnce(attachment))

                    let sourceView = UIImageView()
                    sourceView.frame = audioView.bounds

                    openPreview(sourceView: sourceView)
                } else {
                    // Default behavior for other attachments or when already in previewer
                    onAction?(.userSelect(index))
                }
            }
        }
        
        @objc
        open func pauseAction(_ sender: Button) {
            guard let av = sender.superview as? AttachmentView
            else { return }
            let status = av.lastAttachmentTransferProgress?.attachment.status ?? av.data.transferStatus
            var message: ChatMessage {
                data.message
            }
            var attachment: ChatMessage.Attachment {
                av.data.attachment
            }
            switch status {
            case .pauseUploading, .failedUploading:
                av.update(status: .uploading)
                av.setProgressHandler()
                onAction?(.resumeTransfer(message, attachment))
            case .pauseDownloading, .failedDownloading:
                av.update(status: .downloading)
                av.setProgressHandler()
                onAction?(.resumeTransfer(message, attachment))
            case .uploading:
                av.update(status: .pauseUploading)
                av.setProgressHandler()
                onAction?(.pauseTransfer(message, attachment))
            case .downloading:
                av.update(status: .pauseDownloading)
                av.setProgressHandler()
                onAction?(.pauseTransfer(message, attachment))
            default:
                break
            }
        }
    }
}

public extension MessageCell.AttachmentStackView {
    enum Action {
        case userSelect(Int)
        case pauseTransfer(ChatMessage, ChatMessage.Attachment)
        case resumeTransfer(ChatMessage, ChatMessage.Attachment)
        case play(URL)
        case playedAudio(URL)
        case openedViewOnce(ChatMessage.Attachment)
    }
}
