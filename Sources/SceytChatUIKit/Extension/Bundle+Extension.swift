//
//  Bundle+Extension.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 29.09.22.
//  Copyright © 2022 Sceyt LLC. All rights reserved.
//

import Foundation

extension Bundle {

    /// Returns true if the code is running inside an app extension
    public var isAppExtension: Bool {
        return bundlePath.hasSuffix(".appex")
    }

    /// Returns true if the code is running in the main app (not an extension)
    public static var isMainApp: Bool {
        return !main.isAppExtension
    }
}
