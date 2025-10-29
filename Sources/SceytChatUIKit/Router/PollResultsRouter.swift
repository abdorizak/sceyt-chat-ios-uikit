//
//  PollResultsRouter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

open class PollResultsRouter: Router<PollResultsViewController> {

    open func showPollOptionDetail(option: any PollOptionResultProviding, questionText: String, totalVotes: Int) {
        let viewController = Components.pollOptionDetailViewController.init()
        let viewModel = Components.pollOptionDetailViewModel.init(
            option: option,
            questionText: questionText,
            totalVotes: totalVotes
        )
        viewController.viewModel = viewModel
        rootViewController.show(viewController, sender: self)
    }
}
