//
//  UIImageView+Extension.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 26.10.23.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import UIKit

extension UIImageView {
    // Data holder tap recognizer
    private class TapWithDataRecognizer: UITapGestureRecognizer {
        weak var from: UIViewController?
        var previewer: (() -> PreviewDataSource?)?
        var item: PreviewItem?
        var viewOnce: Bool = false
        var messageText: String?
    }
    
    private var viewController: UIViewController? {
        guard let rootViewController = window?.rootViewController
        else { return nil }
        return rootViewController.presentedViewController != nil ? rootViewController.presentedViewController : rootViewController
    }
    
    func setup(
        previewer: (() -> AttachmentPreviewDataSource?)?,
        item: PreviewItem?,
        from: UIViewController? = nil,
        viewOnce: Bool = false,
        messageText: String? = nil) {
        var _tapRecognizer: TapWithDataRecognizer? = gestureRecognizers?.first(where: { $0 is TapWithDataRecognizer }) as? TapWithDataRecognizer

        isUserInteractionEnabled = true
        clipsToBounds = true

        if _tapRecognizer == nil {
            _tapRecognizer = TapWithDataRecognizer(
                target: self, action: #selector(showImageViewer(_:)))
            _tapRecognizer!.numberOfTouchesRequired = 1
            _tapRecognizer!.numberOfTapsRequired = 1
        }
        // Pass the Data
        _tapRecognizer!.previewer = previewer
        _tapRecognizer!.item = item
        _tapRecognizer!.from = from
        _tapRecognizer!.viewOnce = viewOnce
        _tapRecognizer!.messageText = messageText
        addGestureRecognizer(_tapRecognizer!)
    }
    
    @objc
    private func showImageViewer(_ sender: TapWithDataRecognizer) {
        guard let sourceView = sender.view as? UIImageView else { return }

        // For view-once messages, create a single-item previewer with just the pressed item
        let finalPreviewer: PreviewDataSource
        let initialIndex: Int

        if sender.viewOnce, let item = sender.item {
            // Only open previewer for viewOnce messages when attachment is downloaded
            let attachment = item.attachment
            guard attachment.status == .done else { return }

            finalPreviewer = SingleItemPreviewDataSource(item: item)
            initialIndex = 0
        } else {
            guard let previewer = sender.previewer?(),
                  previewer.canShowPreviewer()
            else { return }
            finalPreviewer = previewer
            initialIndex = sender.item.flatMap { previewer.indexOfItem($0) } ?? 0
        }

        let imageCarousel = Components.mediaPreviewerCarouselViewController.init(
                sourceView: sourceView,
                previewDataSource: finalPreviewer,
                initialIndex: initialIndex,
                viewOnce: sender.viewOnce,
                messageText: sender.messageText)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        let presentFromViewController = sender.from ?? viewController
        presentFromViewController?.present(Components.mediaPreviewerNavigationController.init(imageCarousel), animated: true)
    }
}
