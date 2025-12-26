//
//  MediaPreviewerCarouselViewController.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 26.10.23.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import UIKit

open class MediaPreviewerCarouselViewController: UIPageViewController,
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
{
    public weak var initialSourceView: UIImageView?
    
    open var sourceView: UIImageView? {
        guard let viewController = viewControllers?.first as? MediaPreviewerViewController else {
            return nil
        }
        return initialIndex == viewController.viewModel.index ? initialSourceView : nil
    }
    
    public var sourceFrameRelativeToWindow: CGRect?
    
    open var targetView: UIImageView? {
        guard let viewController = viewControllers?.first as? MediaPreviewerViewController else {
            return nil
        }
        return viewController.targetView
    }
    
    public var previewDataSource: PreviewDataSource?

    private let initialIndex: Int
    public var viewOnce: Bool = false
    public var messageText: String?
    
    private var screenshotObserver: NSObjectProtocol?
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        return blurView
    }()
    
    open var imageContentMode: UIView.ContentMode = .scaleAspectFit
    open lazy var backgroundView = UIView().withoutAutoresizingMask
    open lazy var titleLabel = UILabel()
    open lazy var subtitleLabel = UILabel()
    open lazy var titleView = UIStackView(column: titleLabel, subtitleLabel, alignment: .center)
    
    deinit {
        logger.debug("[PreviewerCarouselViewController] deinit")
        
        initialSourceView?.alpha = 1.0
        NotificationCenter.default.removeObserver(self)
    }
    
    public required init(
        sourceView: UIImageView,
        title: String? = nil,
        subtitle: String? = nil,
        previewDataSource: PreviewDataSource,
        initialIndex: Int = 0,
        viewOnce: Bool = false,
        messageText: String? = nil)
    {
        self.initialSourceView = sourceView
        self.sourceFrameRelativeToWindow = sourceView.frameRelativeToWindow()
        self.initialIndex = initialIndex
        self.previewDataSource = previewDataSource
        self.viewOnce = viewOnce
        self.messageText = messageText
        let pageOptions = [UIPageViewController.OptionsKey.interPageSpacing: 20]

        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: pageOptions)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupAppearance()
        setupLayout()
        setupDone()
        updateRightBarButtonItems()

        if viewOnce {
            setupScreenshotDetection()
        }
    }
    
    open lazy var backButton = UIBarButtonItem(
        image: Images.videoPlayerBack,
        style: .plain,
        target: self,
        action: #selector(dismiss(_:)))
    
    open lazy var shareButton = UIBarButtonItem(
        image: Images.videoPlayerShare,
        style: .plain,
        target: self,
        action: #selector(shareButtonAction(_:)))

    open lazy var oneTimeButton = UIBarButtonItem(
        image: Images.addCircleDashed,
        style: .plain,
        target: self,
        action: #selector(oneTimeButtonAction(_:)))

    public let appearance = Components.mediaPreviewerViewController.appearance
    
    open func setup() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.titleView = titleView
        navigationController?.navigationBar.alpha = 0.0

        dataSource = self
        delegate = self
    }

    open func setupLayout() {
        view.setNeedsLayout()
        view.addSubview(backgroundView)
        backgroundView.pin(to: view)
        view.sendSubviewToBack(backgroundView)
    }

    open func setupAppearance() {
        view.setNeedsDisplay()

        view.backgroundColor = appearance.backgroundColor

        backgroundView.backgroundColor = appearance.backgroundColor
        backgroundView.alpha = 1

        titleLabel.font = appearance.titleLabelAppearance.font
        titleLabel.textColor = appearance.titleLabelAppearance.foregroundColor

        subtitleLabel.font = appearance.subtitleLabelAppearance.font
        subtitleLabel.textColor = appearance.subtitleLabelAppearance.foregroundColor
    }
    
    open func setupDone() {
        if let previewDataSource = previewDataSource,
           let previewItem = previewDataSource.previewItem(at: initialIndex)
        {
            let initialViewController = Components.mediaPreviewerViewController.init()
            initialViewController.viewOnce = self.viewOnce
            initialViewController.messageText = self.messageText
            initialViewController.imageContentMode = imageContentMode
            initialViewController.viewModel = Components.previewerViewModel
                .init(
                    index: initialIndex,
                    previewItem: previewItem)
            previewDataSource.observe(initialViewController.viewModel)
            setViewControllers([initialViewController], direction: .forward, animated: true)
        }
        
        view.subviews.forEach { ($0 as? UIScrollView)?.delaysContentTouches = false }
    }

    private func setupScreenshotDetection() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil)
        
        guard viewOnce else { return }
        // Add blur effect view to the view hierarchy
        view.addSubview(blurEffectView)
        view.bringSubviewToFront(blurEffectView)
        // Listen for app going to background to hide sensitive content
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideContent),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showContent),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc
    private func handleScreenshot() {
        showScreenshotAlert()
    }

    private func showScreenshotAlert() {
        self.showAlert(title: L10n.ViewOnce.Screenshot.Alert.title,
                       message: L10n.ViewOnce.Screenshot.Alert.message,
                       actions: [SheetAction(title: L10n.Alert.Button.ok)])
    }
    
    @objc
    private func hideContent() {
        UIView.animate(withDuration: 0.2) {
            self.blurEffectView.alpha = 1
        }
    }
    
    @objc
    private func showContent() {
        UIView.animate(withDuration: 0.2) {
            self.blurEffectView.alpha = 0
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed,
           let viewController = viewControllers?.first as? MediaPreviewerViewController,
           initialIndex != viewController.viewModel.index
        {
            initialSourceView?.alpha = 1.0
        }
    }
    
    @objc
    private func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    open func shareButtonAction(_ sender: UIBarButtonItem) {
        (viewControllers?.first as? MediaPreviewerViewController)?.shareButtonAction(sender)
    }

    @objc
    open func oneTimeButtonAction(_ sender: UIBarButtonItem) {
        let viewOnceInfoVC = ViewOnceInfoViewController()
        viewOnceInfoVC.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *) {
            if let sheet = viewOnceInfoVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = false
                sheet.preferredCornerRadius = 10
            }
        }

        present(viewOnceInfoVC, animated: true)
    }

    open func updateRightBarButtonItems() {
        var items: [UIBarButtonItem] = []
        if shouldShowOneTimeButton() {
            items.append(oneTimeButton)
        } else {
            items.append(shareButton)
        }
        navigationItem.rightBarButtonItems = items
    }

    open func shouldShowOneTimeButton() -> Bool {
        return viewOnce
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    open func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard !viewOnce else { return nil }
        guard let viewController = viewController as? MediaPreviewerViewController else { return nil }
        guard let previewDataSource = previewDataSource else { return nil }
        let index = viewController.viewModel.index
        guard index <= (previewDataSource.numberOfImages - 2)
        else {
            resetPreviewViewControllerIfNeeded(currentIndex: index)
            return nil
        }
        return previewViewController(for: index + 1)
    }
    
    open func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard !viewOnce else { return nil }
        guard let viewController = viewController as? MediaPreviewerViewController else { return nil }
        let index = viewController.viewModel.index
        guard index > 0
        else {
            resetPreviewViewControllerIfNeeded(currentIndex: index)
            return nil
        }
        return previewViewController(for: index - 1)
    }
    
    open func previewViewController(for index: Int) -> MediaPreviewerViewController? {
        guard let previewItem = previewDataSource?.previewItem(at: index)
        else { return nil }
        let viewController = Components.mediaPreviewerViewController.init()
        viewController.viewOnce = self.viewOnce
        viewController.messageText = self.messageText
        viewController.viewModel = Components.previewerViewModel
            .init(
                index: index,
                previewItem: previewItem)
        previewDataSource?.observe(viewController.viewModel)
        return viewController
    }
    
    open func resetPreviewViewControllerIfNeeded(currentIndex: Int) {
        guard let previewDataSource = previewDataSource else { return }
        if previewDataSource.isLoading {
            previewDataSource.setOnLoading { [weak self] done in
                if let self, done {
                    self.resetPreviewViewControllers()
                }
            }
        } else if currentIndex == 0 || currentIndex > previewDataSource.numberOfImages - 2 {
            previewDataSource.setOnReload { [weak self] in
                self?.resetPreviewViewControllers()
            }
        } else {}
    }
    
    private func resetPreviewViewControllers() {
        _ = viewControllers?
            .compactMap { $0 as? MediaPreviewerViewController }
            .map {
                let item = $0.viewModel.previewItem
                if let index = previewDataSource?.indexOfItem(item) {
                    $0.viewModel = Components.previewerViewModel.init(index: index, previewItem: item)
                }
                $0.bindPreviewItem()
                return $0
            }
//        setViewControllers(resetViewControllers, direction: .forward, animated: false)
    }
}
