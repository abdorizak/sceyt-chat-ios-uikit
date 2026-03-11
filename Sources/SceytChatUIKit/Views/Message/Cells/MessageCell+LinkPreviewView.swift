//
//  MessageCell+LinkPreviewView.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 26.10.23.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import UIKit
import LinkPresentation

extension MessageCell {

    open class LinkPreviewView: View, Measurable {

        public lazy var appearance = Components.messageCell.appearance {
            didSet {
                setupAppearance()
            }
        }

        /// Padding applied to all edges and internal gaps. Defaults to 8.
        /// Must be set before the view is added to a superview (before `setupLayout` runs).
        open var padding: CGFloat = 8

        /// Default padding used by the static `measure` function.
        /// Keep in sync with `padding` if you subclass and change it.
        open class var defaultPadding: CGFloat { 8 }

        open lazy var imageView = ImageView()
            .withoutAutoresizingMask
            .contentMode(.scaleAspectFill)

        open lazy var titleLabel = UILabel()
            .withoutAutoresizingMask
            .contentCompressionResistancePriorityV(.required)

        open lazy var descriptionLabel = UILabel()
            .withoutAutoresizingMask
            .contentCompressionResistancePriorityV(.required)

        open private(set) var link: URL!

        private var imageViewSizeConstraints: [NSLayoutConstraint]?
        private var standardLayoutConstraints = [NSLayoutConstraint]()
        private var compactLayoutConstraints = [NSLayoutConstraint]()
        private var isCompactLayoutActive = false

        open override func setup() {
            super.setup()
            imageView.cornerRadius = 0.0
            layer.cornerRadius = 8.0
            clipsToBounds = true
            imageView.clipsToBounds = true
            titleLabel.numberOfLines = 2
            descriptionLabel.numberOfLines = 3
        }

        open override func setupAppearance() {
            super.setupAppearance()
            titleLabel.font = appearance.linkPreviewAppearance.titleLabelAppearance.font
            titleLabel.textColor = appearance.linkPreviewAppearance.titleLabelAppearance.foregroundColor
            descriptionLabel.font = appearance.linkPreviewAppearance.descriptionLabelAppearance.font
            descriptionLabel.textColor = appearance.linkPreviewAppearance.descriptionLabelAppearance.foregroundColor
        }

        open override func setupLayout() {
            super.setupLayout()
            addSubview(imageView)
            addSubview(titleLabel)
            addSubview(descriptionLabel)
            
            let p = padding

            // Standard layout: image on top, text below
            standardLayoutConstraints = [
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: p),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -p),
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: p),
                descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: p),
                descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -p),
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -p),
            ]

            // Compact layout: image on right, text on left
            compactLayoutConstraints = [
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: p),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -p),
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: p),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: p),
                titleLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -p),
                descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: p),
                descriptionLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -p),
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            ]

            imageViewSizeConstraints = imageView.resize(anchors: [.width, .height])
            NSLayoutConstraint.activate(standardLayoutConstraints)
        }

        open override func layoutSubviews() {
            super.layoutSubviews()
            
        }

        private func applyLayout(compact: Bool) {
            guard compact != isCompactLayoutActive else { return }
            isCompactLayoutActive = compact
            if compact {
                imageView.cornerRadius = 8.0
                NSLayoutConstraint.deactivate(standardLayoutConstraints)
                NSLayoutConstraint.activate(compactLayoutConstraints)
            } else {
                imageView.cornerRadius = 8.0
                NSLayoutConstraint.deactivate(compactLayoutConstraints)
                NSLayoutConstraint.activate(standardLayoutConstraints)
            }
        }

        open var data: MessageLayoutModel.LinkPreview! {
            didSet {
                imageView.image = data.image
                titleLabel.attributedText = data.title
                descriptionLabel.attributedText = data.description
                link = data.url
                guard let imageViewSizeConstraints, imageViewSizeConstraints.count == 2 else { return }
                let compact = data.isCompactLayout && data.image != nil
                applyLayout(compact: compact)
                let size = compact
                    ? Self.compactImageDisplaySize(for: data)
                    : Self.standardImageSize(model: data)
                imageViewSizeConstraints[0].constant = size.width
                imageViewSizeConstraints[1].constant = size.height
            }
        }

        // MARK: - Size helpers

        private static func standardImageSize(model: MessageLayoutModel.LinkPreview) -> CGSize {
            var size = CGSize()
            if let image = model.image {
                if let imageOriginalSize = model.imageOriginalSize,
                    max(imageOriginalSize.width, imageOriginalSize.height) <=
                    max(MessageLayoutModel.defaults.imageAttachmentSize.width, MessageLayoutModel.defaults.imageAttachmentSize.height) {
                    size = imageOriginalSize
                } else {
                    size.width = min(max(model.imageOriginalSize?.width ?? 0, image.size.width), MessageLayoutModel.defaults.imageAttachmentSize.width)
                    size.height = min(max(model.imageOriginalSize?.height ?? 0, image.size.height), MessageLayoutModel.defaults.imageAttachmentSize.height)
                }
            }
            return size
        }

        private static func compactImageDisplaySize(for model: MessageLayoutModel.LinkPreview) -> CGSize {
            return CGSize(width: 52, height: 52)
        }

        open class func measure(model: MessageLayoutModel.LinkPreview, appearance: Appearance) -> CGSize {
            guard model.image != nil || model.title != nil || model.description != nil else {
                return .zero
            }
            let padding = defaultPadding
            let compact = model.isCompactLayout && model.image != nil
            if compact {
                let imgSize = compactImageDisplaySize(for: model)
                // title-to-desc gap matches constraint constant (4)
                let textHeight = model.titleSize.height + model.descriptionSize.height
                    + (model.titleSize.height > 0 && model.descriptionSize.height > 0 ? 4 : 0)
                // both image and text share the same top padding, so: max(52, textH) + top(p) + bottom(p)
                let height = max(imgSize.height, textHeight) + padding * 2
                let textWidth = max(model.titleSize.width, model.descriptionSize.width)
                let maxWidth = MessageLayoutModel.defaults.imageAttachmentSize.width
                let width = min(imgSize.width + padding + textWidth + padding * 2, maxWidth)
                return CGSize(width: width, height: height)
            }

            var size = CGSize()
            if model.image != nil {
                size = standardImageSize(model: model)
            } else {
                size.width = max(model.titleSize.width, model.descriptionSize.width)
            }
            size.height += model.titleSize.height
            size.height += model.descriptionSize.height
            if size.height > 0 {
                // image.top=0, image-to-title gap(p) + title-to-desc gap(4) + bottom padding(p)
                size.height += padding * 2 + 4
            }
            return size
        }
    }
}
