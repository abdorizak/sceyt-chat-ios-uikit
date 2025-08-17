//
//  ChannelViewController+MessagesCollectionView.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 29.09.22.
//  Copyright © 2022 Sceyt LLC. All rights reserved.
//

import UIKit

public extension ChannelViewController {
    open class MessagesCollectionView: CollectionView {
        
        public weak var messagesLayoutDelegate: MessagesCollectionViewLayoutDelegate? {
            didSet {
                layout.messagesLayoutDelegate = messagesLayoutDelegate
            }
        }
        
        /// A flag to indicate if `performBatchUpdates` is currently in progress
        private var isPerformBatchUpdates = false
        /// A flag to delay `reloadData` if called during batch updates
        private var needsReloadData = false
        
        private var scrollToIndexPath: (IndexPath, MessageScrollPosition, Bool)?
        private var animatedScrollToIndexPath: String?
        private var isProgrammaticScrolling = false {
            didSet {
//                animatedScrollToIndexPath = nil
            }
        }
        
        public required init() {
            super.init(
                frame: UIScreen.main.bounds,
                collectionViewLayout: Components.channelMessagesCollectionViewLayout.init()
            )
        }
        
        public required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        public override func setup() {
            super.setup()
            isPrefetchingEnabled = false
            showsHorizontalScrollIndicator = false
            alwaysBounceVertical = true
            contentInset.top = 0
            clipsToBounds = true
            contentInsetAdjustmentBehavior = .always
            
            register(Components.channelOutgoingMessageCell)
            register(Components.channelIncomingMessageCell)
            register(Components.channelDateSeparatorView, kind: .header)
        }
        
        open var layout: ChannelViewController.MessagesCollectionViewLayout {
            guard let layout = collectionViewLayout as? ChannelViewController.MessagesCollectionViewLayout else {
                fatalError("Invalid ChatCollectionViewLayout type")
            }
            return layout
        }
        
        public var safeContentSize: CGSize {
            // Don't use contentSize as the collection view's
            // content size might not be set yet.
            collectionViewLayout.collectionViewContentSize
        }
        
        open var visibleContentRect: CGRect {
            let bounds = self.bounds
            let insetBounds = bounds.inset(by: adjustedContentInset)
            return insetBounds
        }
        
        open var visibleAttributes: [UICollectionViewLayoutAttributes] {
            let visibleLayoutAttributes = layout.layoutAttributesForElements(in: visibleContentRect) ?? []
            return visibleLayoutAttributes
        }
        
        open var lastVisibleAttributes: UICollectionViewLayoutAttributes? {
            let visibleLayoutAttributes = layout.layoutAttributesForElements(in: visibleContentRect) ?? []
            return visibleLayoutAttributes.max(by: { $0.indexPath < $1.indexPath })
        }
        
        open var lastVisibleIndexPath: IndexPath? {
            lastVisibleAttributes?.indexPath
        }
        
        /// Wraps performBatchUpdates with state tracking and safe reload fallback
        open func performUpdates(_ updates: (() -> Void), completion: ((Bool) -> Void)? = nil) {
            isPerformBatchUpdates = true
            performBatchUpdates {
                updates()
            } completion: { [weak self] in
                // Ensure we're back on the main queue before resetting flags and doing reload
                DispatchQueue.main.async {[weak self] in
                    if let self {
                        isPerformBatchUpdates = false
                        if needsReloadData {
                            // Defer actual reload until batch updates are done
                            reloadData()
                            // Ensure layout is updated immediately without waiting for next runloop
                            layoutIfNeeded()
                        }
                        if let (indexPath, pos, animated) = scrollToIndexPath {
                            scrollToItem(
                                at: indexPath,
                                pos: pos,
                                animated: animated
                            )
                        }
                    }
                }
                completion?($0)
            }
        }
        
        /// Override reloadData to prevent crashes if called during performBatchUpdates
        open override func reloadData() {
            // If batch updates are in progress, defer the reload
            if isPerformBatchUpdates {
                needsReloadData = true
                return
            }
            // Safe to reload immediately
            super.reloadData()
            // Force layout update now to avoid visual glitches or async issues
            layoutIfNeeded()
            needsReloadData = false
        }
        
        open func reloadDataAndKeepOffset() {
            setContentOffset(contentOffset, animated: false)
            var id = animatedScrollToIndexPath
            let beforeContentSize = safeContentSize
            
            super.reloadData()
            layoutIfNeeded()
            
            let afterContentSize = safeContentSize
            
            let newOffset = CGPoint(
                x: max(0, contentOffset.x + (afterContentSize.width - beforeContentSize.width)),
                y: max(0, contentOffset.y + (afterContentSize.height - beforeContentSize.height))
            )
            setContentOffset(newOffset, animated: false)
            
            if let id, let attributes = layoutAttributes(forUniqueID: id) {
                debugPrint(
                    "[EVENT] SCROLL TO id: \(id) attributes: \(attributes.indexPath)"
                )
                super.scrollToItem(
                    at: attributes.indexPath,
                    at: .centeredVertically,
                    animated: true
                )
            }
        }
        
        open func reloadDataAndScrollToBottom(animated: Bool = false) {
            setContentOffset(contentOffset, animated: false)
            reloadData()
            scrollToBottom(animated: animated)
        }
        
        open func reloadDataAndScrollTo(
            indexPath: IndexPath,
            pos: MessageScrollPosition = .top,
            animated: Bool = false
        ) {
            reloadDataAndKeepOffset()
            if contains(indexPath: indexPath) {
                scrollToItem(at: indexPath, pos: pos, animated: animated)
            }
        }
        
        open func scrollToItem(at indexPath: IndexPath, pos: MessageScrollPosition = .top, animated: Bool = true) {
            if isPerformBatchUpdates {
                scrollToIndexPath = (indexPath, pos, animated)
                return
            }
            scrollToIndexPath = nil
            if contains(indexPath: indexPath) {
                if animated {
                    debugPrint("[EVENT] SCROLL TO indexPath: \(indexPath)")
                    animatedScrollToIndexPath = (layout
                        .layoutAttributesForItem(
                            at: indexPath
                        ) as? MessagesCollectionViewLayoutAttributes)?.uniqueID
                    
                    if let animatedScrollToIndexPath {
                        DispatchQueue.main
                            .asyncAfter(deadline: .now() + 0.1) {[weak self] in
                                self?.animatedScrollToIndexPath = nil
                            }
                    }
                }
                scrollToItem(
                    at: indexPath,
                    at: pos.collectionViewScrollPosition,
                    animated: animated
                )
            } else {
#if DEBUG
                //            fatalError("scrollToItem at: \(indexPath) out-of-bounds")
#endif
            }
        }
        
        open func scrollToBottom(animated: Bool, animationDuration: TimeInterval = 0.2, completion: ((Bool) -> Void)? = nil) {
            setContentOffset(contentOffset, animated: false)
            let newOffsetY = safeContentSize.height
            - bounds.height
            + contentInset.bottom
            let offsetY = max(-contentInset.top, newOffsetY)
            if animated {
                UIView.animate(
                    withDuration: animationDuration
                ){
                    super.contentOffset = CGPoint(x: 0, y: offsetY)
                    //                super.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                } completion: {
                    completion?($0)
                }
                //            super.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
                //            completion?(true)
            } else {
                super.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                completion?(true)
            }
        }
        
        open func scrollToTop(animated: Bool = true) {
            guard numberOfSections > 0 else { return }
            guard numberOfItems(inSection: numberOfSections - 1) > 0
            else { return }
            let indexPath = IndexPath(
                item: 0,
                section: 0
            )
            scrollToItem(
                at: indexPath,
                at: .top,
                animated: animated
            )
        }
        
        func indexPath(after indexPath: IndexPath) -> IndexPath? {
            var item = indexPath.item + 1
            for section in indexPath.section ..< numberOfSections {
                if item < numberOfItems(inSection: section) {
                    return IndexPath(item: item, section: section)
                }
                item = 0
            }
            return nil
        }
        
        func indexPath(before indexPath: IndexPath) -> IndexPath? {
            var item = indexPath.item - 1
            for section in (0...indexPath.section).reversed() {
                if item >= 0 {
                    return IndexPath(item: item, section: section)
                }
                if section > 0 {
                    item = numberOfItems(inSection: section - 1) - 1
                }
            }
            return nil
        }
        
        func contains(indexPath: IndexPath) -> Bool {
            if indexPath.section < numberOfSections,
               indexPath.item < numberOfItems(inSection: indexPath.section) {
                return true
            }
            return false
        }
        
        private var lastContentOffset: CGPoint = .zero
        private var scrollDisplayLink: CADisplayLink?

        private func startProgrammaticScrollTracking() {
            guard !isProgrammaticScrolling else { return }
            debugPrint("[EVENT] SCROLL TO BEGIN")
            isProgrammaticScrolling = true
            lastContentOffset = contentOffset
            scrollDisplayLink?.invalidate()
            
            let link = CADisplayLink(target: self, selector: #selector(checkProgrammaticScrollProgress))
            link.add(to: .main, forMode: .common)
            scrollDisplayLink = link
        }

        @objc private func checkProgrammaticScrollProgress() {
            // If offset hasn't changed in 2 consecutive frames -> scroll finished
            if contentOffset.equalTo(lastContentOffset) {
                debugPrint("[EVENT] SCROLL TO END")
                finishProgrammaticScroll()
            } else {
                lastContentOffset = contentOffset
            }
        }

        private func finishProgrammaticScroll() {
            scrollDisplayLink?.invalidate()
            scrollDisplayLink = nil
            isProgrammaticScrolling = false
        }

        open override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
//            if animated {
//                startProgrammaticScrollTracking()
//            }
            super.setContentOffset(contentOffset, animated: animated)
        }

        open override func scrollToItem(
            at indexPath: IndexPath,
            at scrollPosition: UICollectionView.ScrollPosition,
            animated: Bool
        ) {
            if animated {
                startProgrammaticScrollTracking()
            }
            super.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        }
        
        func layoutAttributes(forUniqueID uniqueID: String) -> MessagesCollectionViewLayoutAttributes? {
            guard let layout = collectionViewLayout as? MessagesCollectionViewLayout else {
                return nil
            }
            
            var allAttributes: [MessagesCollectionViewLayoutAttributes] = []
            
            let sections = numberOfSections ?? 0
            for section in 0 ..< sections {
                let items = numberOfItems(inSection: section) ?? 0
                for item in 0 ..< items {
                    let indexPath = IndexPath(item: item, section: section)
                    if let attrs = layout.layoutAttributesForItem(at: indexPath) as? MessagesCollectionViewLayoutAttributes {
                        if attrs.uniqueID == uniqueID {
                            return attrs
                        }
                    }
                }
            }
            
            return nil
        }
    }
}

public extension ChannelViewController.MessagesCollectionView {
    
    public struct MessageScrollPosition: OptionSet {
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let top       = MessageScrollPosition(rawValue: 1 << 0)
        public static let centered  = MessageScrollPosition(rawValue: 1 << 1)
        public static let bottom    = MessageScrollPosition(rawValue: 1 << 2)
        
        public var collectionViewScrollPosition: UICollectionView.ScrollPosition {
               var result: UICollectionView.ScrollPosition = []
               if contains(.top)        { result.insert(.top) }
               if contains(.centered)   { result.insert(.centeredVertically) }
               if contains(.bottom)     { result.insert(.bottom) }
               return result
           }
    }
    
}

public extension ChannelViewController.MessagesCollectionView {
    
    func findCell(forGesture sender: UIGestureRecognizer) -> UICollectionViewCell? {
        // Collection view is a scroll view; we want to ignore
        // cells that are scrolled offscreen.  So we first check
        // that the collection view contains the gesture location.
        guard contains(gestureRecognizer: sender)
        else { return nil }

        for cell in visibleCells {
            guard cell.contains(gestureRecognizer: sender)
            else { continue }
            return cell
        }
        return nil
    }
}
