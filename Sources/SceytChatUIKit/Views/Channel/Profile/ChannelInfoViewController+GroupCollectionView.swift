//
//  ChannelInfoViewController+GroupCollectionView.swift
//  SceytChatUIKit
//
//  Created by Sceyt on 12.12.2024.
//  Copyright © 2024 Sceyt LLC. All rights reserved.
//

import UIKit
import SceytChat

extension ChannelInfoViewController {
    open class GroupCollectionView: ChannelInfoViewController.AttachmentCollectionView,
                                     UICollectionViewDelegate,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout {

        public var settings = Layout.Settings(sectionInset: .zero,
                                              interitemSpacing: 0,
                                              lineSpacing: 0,
                                              sectionHeadersPinToVisibleBounds: false)

        open var channel: ChatChannel?
        open var groups: [ChannelLayoutModel] = []
        private var query: ChannelListQuery?
        private var isLoading = false
        private var hasMore = true
        private let pageLimit = 10
        open var onSelect: ((ChannelLayoutModel) -> Void)?

        open var layout: Layout? { collectionViewLayout as? Layout }

        public required init() {
            super.init(frame: .zero, collectionViewLayout: Layout(settings: settings))
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        open override func setup() {
            super.setup()

            noItemsMessage = L10n.Channel.Info.Segment.Groups.noItems
            noItemsMessageSubTitle = L10n.Channel.Info.Segment.Groups.noItemsSubTitle
            noItemsIcon = UIImage.emptyGroups
            register(Components.channelInfoGroupCell.self)
            delegate = self
            dataSource = self
        }

        open override func setupAppearance() {
            super.setupAppearance()
            backgroundColor = appearance.backgroundColor
        }

        open override func setupDone() {
            super.setupDone()
            // Load groups data here if needed
            loadGroups()
        }

        open override func layoutSubviews() {
            super.layoutSubviews()
            
            layout?.itemSize = .init(width: width,
                                     height: Layouts.cellHeight)
        }

        open func loadGroups() {
            guard let channel = channel,
                  channel.isDirect,
                  let peerId = channel.peer?.id,
                  !isLoading else {
                updateNoItems()
                return
            }

            isLoading = true

            // Create query for mutual groups
            query = ChannelListQuery.Builder()
                .mutual(withUserId: peerId)
                .types(SceytChatUIKit.shared.config.mutualGroupChannelTypes)
                .limit(UInt(pageLimit))
                .build()

            query?.loadNext { [weak self] _, channels, error in
                guard let self = self else { return }

                self.isLoading = false

                if let error = error {
                    logger.error("Failed to load mutual groups: \(error)")
                    self.updateNoItems()
                    return
                }

                if let channels = channels {
                    self.groups = channels.map {
                        ChannelLayoutModel(
                            channel: ChatChannel(channel: $0),
                            appearance: Components.channelCell.appearance
                        )
                    }
                    // Check if we received fewer items than requested
                    self.hasMore = channels.count >= self.pageLimit
                    self.reloadData()
                    self.updateNoItems()
                }
            }
        }

        public func numberOfSections(in collectionView: UICollectionView) -> Int {
            1
        }

        open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            groups.count
        }

        open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: Components.channelInfoGroupCell.self)
            let group = groups[indexPath.item]
            cell.parentAppearance = appearance.cellAppearance
            cell.data = group
            return cell
        }

        open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let group = groups[indexPath.item]
            onSelect?(group)
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            // Load more groups when reaching the last item
            if indexPath.item == groups.count - 1 {
                loadMoreGroups()
            }
        }

        open func loadMoreGroups() {
            guard let query = query,
                  hasMore,
                  !isLoading else {
                return
            }

            isLoading = true

            query.loadNext { [weak self] _, channels, error in
                guard let self = self else { return }

                self.isLoading = false

                if let error = error {
                    logger.error("Failed to load more mutual groups: \(error)")
                    return
                }

                if let channels = channels {
                    let newGroups = channels.map {
                        ChannelLayoutModel(
                            channel: ChatChannel(channel: $0),
                            appearance: Components.channelCell.appearance
                        )
                    }
                    let startIndex = self.groups.count
                    self.groups.append(contentsOf: newGroups)

                    // Check if we received fewer items than requested
                    self.hasMore = channels.count >= self.pageLimit

                    // Insert new items using batch updates to avoid glitches during fast scrolling
                    let indexPaths = (startIndex..<self.groups.count).map { IndexPath(item: $0, section: 0) }
                    self.performBatchUpdates({
                        self.insertItems(at: indexPaths)
                    }, completion: nil)
                    self.updateNoItems()
                }
            }
        }
    }
}

public extension ChannelInfoViewController.GroupCollectionView {
    enum Layouts {
        public static var horizontalPadding: CGFloat = 16
        public static var verticalPadding: CGFloat = 8
        public static var cellHeight: CGFloat = 64 // avatarSize (48) + verticalPadding * 2 (8 * 2 = 16)
    }
}
