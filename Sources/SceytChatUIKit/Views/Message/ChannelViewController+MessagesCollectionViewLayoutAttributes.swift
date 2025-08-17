//
//  ChannelViewController+MessagesCollectionViewLayoutAttributes.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 29.09.22.
//  Copyright © 2022 Sceyt LLC. All rights reserved.
//

import UIKit

public extension ChannelViewController {
    open class MessagesCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
        public var uniqueID: String?
        internal static var observeIndexPath: ((MessagesCollectionViewLayoutAttributes, IndexPath) -> Void)?
        
        
        open override func copy(with zone: NSZone? = nil) -> Any {
            guard let copy = super.copy(with: zone) as? MessagesCollectionViewLayoutAttributes else {
                return super.copy(with: zone)
            }
            copy.uniqueID = uniqueID
            if uniqueID == nil {
                Self.observeIndexPath?(self, indexPath)
            }
            return copy
        }
        
        open override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? MessagesCollectionViewLayoutAttributes else {
                return false
            }
            if uniqueID != other.uniqueID {
                return false
            }
            return super.isEqual(object)
        }
        
        open override var indexPath: IndexPath {
            didSet {
                Self.observeIndexPath?(self, indexPath)
            }
        }
    }

}
