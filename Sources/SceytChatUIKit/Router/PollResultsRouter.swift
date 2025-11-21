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

    open func showProfile(user: ChatUser) {
        // Use a temporary channel ID just to create the provider instance
        // The getLocalChannel method doesn't actually use the channelId from the provider
        let channelProvider = Components.channelProvider.init(channelId: 0)
        let channelCreator = Components.channelCreator.init()

        guard let me = SceytChatUIKit.shared.currentUserId else { return }
        guard user.id != me else { return }

        loader.isLoading = true

        channelProvider.getLocalChannel(
            type: SceytChatUIKit.shared.config.channelTypesConfig.direct,
            userId: user.id
        ) { [weak self] channel in
            guard let self else { return }

            if let channel {
                loader.isLoading = false
                self.showChannelInfoViewController(channel: channel)
            } else {
                let member = ChatChannelMember(
                    user: user,
                    roleName: SceytChatUIKit.shared.config.memberRolesConfig.owner
                )

                channelCreator.createLocalChannelByMembers(
                    type: SceytChatUIKit.shared.config.channelTypesConfig.direct,
                    members: [
                        member,
                        ChatChannelMember(id: me, roleName: SceytChatUIKit.shared.config.memberRolesConfig.owner)
                    ]
                ) { [weak self] channel, error in
                    guard let self else { return }
                    loader.isLoading = false

                    if let channel {
                        self.showChannelInfoViewController(channel: channel)
                    } else if let error {
                        self.showAlert(error: error)
                    }
                }
            }
        }
    }

    open func showChannelInfoViewController(channel: ChatChannel) {
        let viewController = Components.channelInfoViewController.init()
        viewController.hidesBottomBarWhenPushed = true
        viewController.profileViewModel = Components.channelProfileViewModel.init(
            channel: channel,
            appearance: MessageCell.appearance
        )
        rootViewController.show(viewController, sender: self)
    }
}
