//
//  UIColor+Extensions.swift
//  SceytDemoApp
//
//  Created by Sergey Charchoghlyan on 17.06.25.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension UIColor {
    var light: UIColor {
        resolvedColor(with: .init(userInterfaceStyle: .light))
    }
    
    var dark: UIColor {
        resolvedColor(with: .init(userInterfaceStyle: .dark))
    }
}
