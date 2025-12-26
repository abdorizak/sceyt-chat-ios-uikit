//
//  MessageCell+AttachmentImageView.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 29.09.22.
//  Copyright © 2022 Sceyt LLC. All rights reserved.
//

import SceytChat
import UIKit

extension MessageCell {
    open class AttachmentImageView: AttachmentView {

        open lazy var blurEffectView: UIVisualEffectView = {
            let blur = UIBlurEffect(style: .light)
            let view = UIVisualEffectView(effect: blur)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isUserInteractionEnabled = false
            view.isHidden = true
            return view
        }()

        open lazy var fireIconContainerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor(hex: "#17191C", alpha: 0x66 / 255.0)
            view.layer.cornerRadius = 28
            view.isUserInteractionEnabled = false
            view.isHidden = true
            return view
        }()

        open lazy var fireIconView: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFit
            view.image = .fire
            view.tintColor = .white
            view.isUserInteractionEnabled = false
            return view
        }()

        override open func setupAppearance() {
            super.setupAppearance()
            imageView.clipsToBounds = true
            blurEffectView.clipsToBounds = true

            progressView.contentInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
            progressView.backgroundColor = .black.withAlphaComponent(0.3)
        }

        override open func setupLayout() {
            super.setupLayout()
            addSubview(imageView)
            addSubview(blurEffectView)
            addSubview(fireIconContainerView)
            fireIconContainerView.addSubview(fireIconView)
            addSubview(progressView)
            addSubview(pauseButton)

            imageView.pin(to: self)
            blurEffectView.pin(to: imageView)

            progressView.resize(anchors: [.width(56), .height(56)])
            progressView.pin(to: imageView, anchors: [.centerX, .centerY])
            pauseButton.pin(to: progressView)

            fireIconContainerView.resize(anchors: [.width(56), .height(56)])
            fireIconContainerView.pin(to: imageView, anchors: [.centerX, .centerY])

            fireIconView.resize(anchors: [.width(32), .height(32)])
            fireIconView.pin(to: fireIconContainerView, anchors: [.centerX, .centerY])
        }

        override open func layoutSubviews() {
            super.layoutSubviews()
            // Match the blur view's corner radius to the image view
            blurEffectView.layer.cornerRadius = 16.0
        }

        private var filePath: String?

        override open var data: MessageLayoutModel.AttachmentLayout! {
            didSet {
                setupPreviewer()
                filePath = data.attachment.filePath
                imageView.image = data.thumbnail

                // Show/hide blur and fire icon based on viewOnce
                let isViewOnce = data.ownerMessage?.isViewOnceMessage ?? false
                blurEffectView.isHidden = !isViewOnce
                fireIconContainerView.isHidden = !isViewOnce
                
                if data.ownerMessage?.id == 763885519683002368 {
                    print("data.ownerMessage?.id")
                }

                data.onLoadThumbnail = { [weak self] thumbnail in
                    guard let self else {
                        logger.verbose("[Attachment] onLoadThumbnail self is nil")
                        return
                    }
                    self.imageView.image = data.attachment.thumbnailImage ?? thumbnail
                }
            }
        }
    }
}
