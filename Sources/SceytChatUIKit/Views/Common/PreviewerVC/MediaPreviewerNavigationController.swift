//
//  MediaPreviewerNavigationController.swift
//  SceytChatUIKit
//
//  Created by Duc on 11/10/2023.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import UIKit

open class MediaPreviewerNavigationController: NavigationController, PreviewerTransitionViewControllerConvertible {
    private let mediaPreviewerCarouselViewController: MediaPreviewerCarouselViewController
    var sourceView: UIImageView? { mediaPreviewerCarouselViewController.sourceView }
    var sourceFrameRelativeToWindow: CGRect? { mediaPreviewerCarouselViewController.sourceFrameRelativeToWindow }
    var targetView: UIImageView? { mediaPreviewerCarouselViewController.targetView }

    private let imageViewerPresentationDelegate: ImageViewerTransitionPresentationManager?

    required public init(_ mediaPreviewerCarouselViewController: MediaPreviewerCarouselViewController) {
        let viewOnce = mediaPreviewerCarouselViewController.viewOnce
        self.imageViewerPresentationDelegate = viewOnce ? nil : ImageViewerTransitionPresentationManager(imageContentMode: mediaPreviewerCarouselViewController.imageContentMode)
        self.mediaPreviewerCarouselViewController = mediaPreviewerCarouselViewController
        super.init(rootViewController: mediaPreviewerCarouselViewController)

        if !viewOnce {
            transitioningDelegate = imageViewerPresentationDelegate
            modalPresentationStyle = .custom
        } else {
            modalPresentationStyle = .fullScreen
        }
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
