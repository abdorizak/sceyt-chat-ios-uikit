//
//  NSPredicate+Extension.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 26.10.23.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import Foundation

extension NSCompoundPredicate {
    
    class func andPredicate(_ predicates: NSPredicate...) -> NSCompoundPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension NSPredicate {
    
    func and(predicate: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [self, predicate])
    }
    
    func or(predicate: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: [self, predicate])
    }
}
