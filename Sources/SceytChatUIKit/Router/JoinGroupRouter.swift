//
//  JoinGroupRouter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit
import SceytChat

open class JoinGroupRouter: Router<JoinGroupViewController> {
    
    open func showChannel(_ channel: ChatChannel) {
        // Dismiss the current join group view controller
        rootViewController.dismiss(animated: true) { [weak self] in
            // Navigate to the joined channel
            self?.navigateToChannel(channel)
        }
    }
    
    private func navigateToChannel(_ channel: ChatChannel) {
        // Use the channel list router to show the channel
        ChannelListRouter.showChannel(channel)
    }
}
