//
//  PollVoteResendOperation.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import SceytChat
import Foundation

open class PollVoteResendOperation: AsyncOperation {
    let provider: ChannelMessageProvider
    let messageId: MessageId
    let pollId: String
    let optionId: String
    let isAdd: Bool
    
    public init(
        provider: ChannelMessageProvider,
        messageId: MessageId,
        pollId: String,
        optionId: String,
        isAdd: Bool
    ) {
        self.provider = provider
        self.messageId = messageId
        self.pollId = pollId
        self.optionId = optionId
        self.isAdd = isAdd
        super.init(String(provider.channelId))
    }
    
    override open func main() {
        if isAdd {
            addVote { [weak self] in
                self?.complete()
            }
        } else {
            deleteVote { [weak self] in
                self?.complete()
            }
        }
    }
    
    private func addVote(_ completion: @escaping () -> Void) {
        logger.verbose("SyncService: Resending Poll Vote Add with messageId \(messageId), pollId: \(pollId), optionId: \(optionId)")
        provider.addPollVote(
            messageId: messageId,
            pollId: pollId,
            optionId: optionId,
            storeForResend: false
        ) { error in
            logger.errorIfNotNil(error, "SyncService: Resending Poll Vote Add with messageId \(self.messageId), pollId: \(self.pollId), optionId: \(self.optionId)")
            completion()
        }
    }
    
    private func deleteVote(_ completion: @escaping () -> Void) {
        logger.verbose("SyncService: Resending Poll Vote Delete with messageId \(messageId), pollId: \(pollId), optionId: \(optionId)")
        provider.deletePollVote(
            messageId: messageId,
            pollId: pollId,
            optionId: optionId,
            storeForResend: false
        ) { error in
            logger.errorIfNotNil(error, "SyncService: Resending Poll Vote Delete with messageId \(self.messageId), pollId: \(self.pollId), optionId: \(self.optionId)")
            completion()
        }
    }
}

