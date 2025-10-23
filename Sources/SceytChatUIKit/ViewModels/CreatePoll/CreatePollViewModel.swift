//
//  CreatePollViewModel.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import Combine

open class CreatePollViewModel: NSObject {

    @Published public var poll: CreatePollModel
    @Published public var event: Event?
    @Published public var isLoading = false
    @Published public var error: Error?
    
    public var maxOptionsCount: Int = 12

    public required init(poll: CreatePollModel = CreatePollModel()) {
        self.poll = poll
        super.init()
    }

    // MARK: - Question

    public func updateQuestion(_ question: String) {
        poll.question = question
    }

    // MARK: - Options

    public func updateOption(at index: Int, value: String) {
        guard index < poll.options.count else { return }
        poll.options[index] = value
    }

    public func addOption() {
        guard poll.options.count < maxOptionsCount else { return }
        poll.options.append("")
        event = .reloadData
    }
    
    public var canAddMoreOptions: Bool {
        poll.options.count < maxOptionsCount
    }

    public func removeOption(at index: Int) {
        guard poll.options.count > 2, index < poll.options.count else { return }
        poll.options.remove(at: index)
        event = .reloadData
    }

    public func moveOption(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex < poll.options.count,
              destinationIndex < poll.options.count,
              sourceIndex != destinationIndex else { return }

        let option = poll.options.remove(at: sourceIndex)
        poll.options.insert(option, at: destinationIndex)
    }

    // MARK: - Parameters

    public func updateAllowMultipleAnswers(_ value: Bool) {
        poll.allowMultipleAnswers = value
    }

    public func updateShowVoterNames(_ value: Bool) {
        poll.showVoterNames = value
    }

    public func updateAllowAddingOptions(_ value: Bool) {
        poll.allowAddingOptions = value
    }

    // MARK: - Validation

    public var canCreatePoll: Bool {
        poll.isValid
    }
}

public extension CreatePollViewModel {
    enum Event {
        case reloadData
        case pollCreated(CreatePollModel)
    }
}
