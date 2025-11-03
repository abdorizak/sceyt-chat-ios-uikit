//
//  PollResultsRouter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit
import SceytChat

open class PollResultsRouter: Router<PollResultsViewController> {

    open func showPollOptionDetail(option: PollOption, pollDetails: PollDetails, messageID: MessageId) {
        let viewController = Components.pollOptionDetailViewController.init()
        let viewModel = Components.pollOptionDetailViewModel.init(
            option: option,
            pollDetails: pollDetails,
            messageID: messageID
        )
        viewController.viewModel = viewModel
        rootViewController.show(viewController, sender: self)
    }
}
