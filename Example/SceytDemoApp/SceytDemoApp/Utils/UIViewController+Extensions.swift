//
//  UIViewController+Extensions.swift
//  SceytDemoApp
//
//  Created by Sergey Charchoghlyan on 17.06.25.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import SceytChatUIKit
import UIKit

extension UIViewController {
    @discardableResult
    func showSheet(_ child: UIView,
                   style: SheetViewController.Style = .bottom,
                   backgroundDismiss: Bool = true,
                   cornerRadius: CGFloat? = nil,
                   title: String? = nil,
                   onShow: (() -> Void)? = nil,
                   onDone: (() -> Void)? = nil,
                   animated: Bool = true) -> SheetViewController
    {
        let viewController = SheetViewController(child: child,
                         style: style,
                         backgroundDismiss: backgroundDismiss,
                         cornerRadius: cornerRadius,
                         title: title,
                         onShow: onShow,
                         onDone: onDone)
        
        let presenter: UIViewController
        if let tabbar = tabBarController {
            presenter = tabbar
        } else if let nav = navigationController {
            presenter = nav
        } else {
            presenter = self
        }
        presenter.present(viewController, animated: false) { [weak viewController] in
            viewController?.show(animated: animated)
        }
        return viewController
    }
    
    @discardableResult
    func showBottomSheet(title: String? = nil, actions: [SheetAction], withCancel: Bool = false) -> SheetViewController {
        let viewController = SheetViewController(child: BottomSheet(title: title,
                                            actions: actions + (withCancel ? [.init(title: L10n.Alert.Button.cancel, style: .cancel)] : [])),
                         style: .floating(),
                         cornerRadius: 0,
                         onCancel: {
                             actions.first(where: { $0.style == .cancel })?.handler?()
                         })
        let presenter: UIViewController
        if let tabbar = tabBarController {
            presenter = tabbar
        } else if let nav = navigationController {
            presenter = nav
        } else {
            presenter = self
        }
        presenter.present(viewController, animated: false) { [weak viewController] in
            viewController?.show()
        }
        return viewController
    }
    
    func dismissSheet(animated: Bool = true, completion: (() -> Void)? = nil) {
        var sheetViewController: SheetViewController?
        if let viewController = self as? SheetViewController {
            sheetViewController = viewController
        } else if let viewController = presentedViewController as? SheetViewController {
            sheetViewController = viewController
        }
        if let sheetViewController {
            sheetViewController.dismiss(animated: animated) {
                completion?()
            }
        } else {
            completion?()
        }
    }
}

