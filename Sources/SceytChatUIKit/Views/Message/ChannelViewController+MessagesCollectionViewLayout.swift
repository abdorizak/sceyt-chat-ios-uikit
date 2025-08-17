//
//  ChannelViewController+MessagesCollectionViewLayout.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 29.09.22.
//  Copyright © 2022 Sceyt LLC. All rights reserved.
//

import UIKit

public protocol MessagesCollectionViewLayoutDelegate: AnyObject {
    func uniqueIDForItem(at indexPath: IndexPath) -> String?
}

public extension ChannelViewController {
    open class MessagesCollectionViewLayout: UICollectionViewFlowLayout {
        
        public weak var messagesLayoutDelegate: MessagesCollectionViewLayoutDelegate?
        
        public required override init() {
            super.init()
            MessagesCollectionViewLayoutAttributes.observeIndexPath = {[weak self] attributes, indexPath in
                guard let self else { return }
                attributes.uniqueID = messagesLayoutDelegate?
                    .uniqueIDForItem(at: indexPath)
            }
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        open override class var layoutAttributesClass: AnyClass {
            MessagesCollectionViewLayoutAttributes.self
        }
        
        open override func prepare() {
            super.prepare()
        }
        
        open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            true
        }
        
        open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
            super.invalidateLayout(with: context)
        }
        
        open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            guard let attributes = super.layoutAttributesForItem(at: indexPath) as? MessagesCollectionViewLayoutAttributes else {
                return super.layoutAttributesForItem(at: indexPath)
            }
            
            attributes.uniqueID = messagesLayoutDelegate?
                .uniqueIDForItem(at: indexPath)
            return attributes
        }
    }
}
