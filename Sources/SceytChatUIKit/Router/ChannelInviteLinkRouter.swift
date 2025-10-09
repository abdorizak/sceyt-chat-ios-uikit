//
//  ChannelInviteLinkRouter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

open class ChannelInviteLinkRouter: Router<ChannelInviteLinkViewController> {

    open func showRecentLinks() {
        // TODO: Implement recent links view
    }

    open func showQRCode() {
        guard let inviteLink = rootViewController.inviteLinkViewModel?.inviteLink else { return }
        let qrCodeViewController = Components.qrCodeViewController.init()
        qrCodeViewController.inviteLink = inviteLink

        qrCodeViewController.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *) {
            if let sheet = qrCodeViewController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 10
            }
        }

        rootViewController.present(qrCodeViewController, animated: true)
    }
}
