//
//  MessageCell+PollView.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

extension MessageCell {
    open class PollView: View, MessageCellMeasurable {

        open lazy var appearance: MessageCellAppearance = Components.messageCell.appearance {
            didSet {
                setupAppearance()
            }
        }

        open lazy var questionLabel = UILabel()
            .withoutAutoresizingMask

        open lazy var typeLabel = UILabel()
            .withoutAutoresizingMask

        open lazy var optionsStackView = UIStackView()
            .withoutAutoresizingMask

        private var optionViews: [Int: PollOptionView] = [:]
        
        // Store the current PollViewModel to pass with actions
        private(set) var pollViewModel: PollViewModel?
        
        open lazy var separatorView = UIView()
            .withoutAutoresizingMask

        open lazy var viewResultButton = UIButton()
            .withoutAutoresizingMask

        open var data: MessageLayoutModel? {
            didSet {
                guard let data = data else {
                    isHidden = true
                    return
                }

                backgroundColor = data.message.incoming ? appearance.incomingBubbleColor : appearance.outgoingBubbleColor

                // Check if message has poll data and is not deleted
                guard data.message.poll != nil, data.message.state != .deleted else {
                    isHidden = true
                    return
                }

                isHidden = false
                configure(with: data)
            }
        }

        public var onDidTapOption: ((Int, PollViewModel) -> Void)?
        public var onDidTapViewResults: (() -> Void)?
        
        override open func setup() {
            super.setup()

            layer.cornerRadius = 16
            optionsStackView.axis = .vertical
            optionsStackView.spacing = appearance.pollViewAppearance.optionSpacing
            separatorView.backgroundColor = .white
            questionLabel.numberOfLines = 0
            viewResultButton.setTitle("View Results", for: .normal)
            viewResultButton.setTitleColor(.systemBlue, for: .normal)
            viewResultButton.addTarget(self, action: #selector(viewResultsButtonTapped), for: .touchUpInside)

            viewResultButton.contentEdgeInsets = UIEdgeInsets(top: 16.0, left: 10.0, bottom: 16.0, right: 10.0)
        }

        override open func setupLayout() {
            super.setupLayout()

            addSubview(questionLabel)
            addSubview(typeLabel)
            addSubview(optionsStackView)
            addSubview(separatorView)
            addSubview(viewResultButton)

            questionLabel.pin(to: self, anchors: [.leading(12.0), .trailing(-12.0), .top(8.0)])
            typeLabel.pin(to: questionLabel, anchors: [.leading, .trailing])
            typeLabel.topAnchor.pin(to: questionLabel.bottomAnchor, constant: 4.0)

            optionsStackView.pin(to: self, anchors: [.leading(12.0), .trailing(-12.0)])
            optionsStackView.topAnchor.pin(to: typeLabel.bottomAnchor, constant: 16.0)

            separatorView.topAnchor.pin(to: optionsStackView.bottomAnchor, constant: 20.0)
            separatorView.pin(to: self, anchors: [.leading(4.0), .trailing(-4.0)])
            separatorView.resize(anchors: [.height(1.0)])
            viewResultButton.topAnchor.pin(to: separatorView.bottomAnchor)
            viewResultButton.pin(to: self, anchors: [.leading, .trailing])
        }

        override open func setupAppearance() {
            super.setupAppearance()

            backgroundColor = .clear

            questionLabel.font = appearance.pollViewAppearance.questionTextStyle.font
            questionLabel.textColor = appearance.pollViewAppearance.questionTextStyle.foregroundColor

            typeLabel.font = appearance.pollViewAppearance.pollTypeTextStyle.font
            typeLabel.textColor = appearance.pollViewAppearance.pollTypeTextStyle.foregroundColor

            separatorView.backgroundColor = appearance.pollViewAppearance.dividerColor

            viewResultButton.setTitleColor(appearance.pollViewAppearance.viewResultsTextStyle.foregroundColor, for: .normal)
            viewResultButton.titleLabel?.font = appearance.pollViewAppearance.viewResultsTextStyle.font
        }

        private func configure(with layoutModel: MessageLayoutModel) {
            let message = layoutModel.message

            guard let poll = message.poll, message.state != .deleted else {
                isHidden = true
                return
            }

            let viewModel = PollViewModel(from: poll, isIncmoing: layoutModel.message.incoming)
            // Store the current PollViewModel
            self.pollViewModel = viewModel
            
            questionLabel.text = viewModel.question
            typeLabel.text = viewModel.pollTypeText

            let isAnonymous = viewModel.anonymous
            viewResultButton.isHidden = isAnonymous
            separatorView.isHidden = isAnonymous

            // Remove existing option views
            optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            optionViews.removeAll()

            // Add option views
            for (index, option) in viewModel.options.enumerated() {
                let optionView = createOptionView(option: option, index: index)
                optionsStackView.addArrangedSubview(optionView)
                optionViews[index] = optionView
            }
        }

        private func createOptionView(
            option: PollOptionViewModel,
            index: Int,
        ) -> PollOptionView {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            let optionView = PollOptionView()
            optionView.viewModel = option
            optionView.addGestureRecognizer(tapGesture)
            optionView.tag = index
            return optionView
        }

        @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
            guard let view = sender.view,
                  let pollOptionView = view as? PollOptionView,
                  let data = data,
                  let currentPollViewModel = pollViewModel,
                  !currentPollViewModel.closed else { return }
            // Check if interaction is disabled (vote in progress)
            guard view.isUserInteractionEnabled else { return }
            let index = view.tag
            onDidTapOption?(index, currentPollViewModel)
        }

        open func updatePoll(poll: PollViewModel) {
            // Update stored PollViewModel
            self.pollViewModel = poll
            for (index, option) in poll.options.enumerated() {
                self.updateOption(with: option, at: index, animated: true)
            }
        }

        /// Update the UI for a specific poll option optimistically
        open func updateOption(with viewModel: PollOptionViewModel, at index: Int, animated: Bool = false) {
            guard let optionView = optionViews[index],
                  let data = data,
                  let poll = data.message.poll,
                  index >= 0 && index < poll.options.count else {
                return
            }

            if animated {
                optionView.updateViewModel(viewModel)
            } else {
                optionView.viewModel = viewModel
            }
        }

        @objc private func viewResultsButtonTapped() {
            onDidTapViewResults?()
        }

        open class func measure(
            model: MessageLayoutModel,
            appearance: MessageCell.Appearance
        ) -> CGSize {
            guard let poll = model.message.poll, model.message.state != .deleted else {
                return .zero
            }

            let pollViewModel = PollViewModel(from: poll, isIncmoing: model.message.incoming)
            let pollAppearance = appearance.pollViewAppearance
            let maxWidth = Components.messageLayoutModel.defaults.messageWidth - 24 // 12pt padding each side
            var height: CGFloat = 0

            // Top padding
            height += 8 // questionLabel top padding

            // Question height
            let questionConfig = TextSizeMeasure.Config(
                restrictingWidth: maxWidth - 24, // 12pt leading + 12pt trailing
                maximumNumberOfLines: 0,
                font: pollAppearance.questionTextStyle.font,
                lastFragmentUsedRect: false
            )
            let questionSize = TextSizeMeasure.calculateSize(of: pollViewModel.question, config: questionConfig).textSize
            height += ceil(questionSize.height)

            // Type label height + spacing
            height += 4 // spacing between question and type
            let typeConfig = TextSizeMeasure.Config(
                restrictingWidth: maxWidth - 24,
                maximumNumberOfLines: 1,
                font: pollAppearance.pollTypeTextStyle.font,
                lastFragmentUsedRect: false
            )
            let typeSize = TextSizeMeasure.calculateSize(of: pollViewModel.pollTypeText, config: typeConfig).textSize
            height += ceil(typeSize.height)

            // Options stack top spacing
            height += 16 // spacing between typeLabel and optionsStackView

            // Options height
            // Calculation: maxWidth already has -24 (12pt padding each side)
            // Inside option view: 20pt checkbox + 8pt spacing + 8pt spacing + 80pt voters container = 116pt
            let optionConfig = TextSizeMeasure.Config(
                restrictingWidth: maxWidth - 116, // 20pt checkbox + 8pt spacing + 8pt spacing + 80pt voters container
                maximumNumberOfLines: 0,
                font: pollAppearance.optionTextStyle.font,
                lastFragmentUsedRect: false
            )
            let optionSpacing = pollAppearance.optionSpacing
            let optionMinHeight: CGFloat = 34 // checkbox (20pt) + spacing (8pt) + progress bar (6pt)

            for (index, option) in pollViewModel.options.enumerated() {
                let optionTextSize = TextSizeMeasure.calculateSize(of: option.text, config: optionConfig).textSize
                let optionHeight = max(ceil(optionTextSize.height) + 8 + 6, optionMinHeight) // text + spacing (8pt) + progress bar (6pt), minimum 34pt
                height += optionHeight
                if index < pollViewModel.options.count - 1 {
                    height += optionSpacing
                }
            }

            // Separator + footer (if not anonymous)
            if !pollViewModel.anonymous {
                height += 20 // separator top spacing
                height += 1 // separator height
                height += 30 // button height (16pt top + 16pt bottom contentEdgeInsets + ~16pt intrinsic height)
            }

            return CGSize(width: maxWidth, height: ceil(height))
        }
    }
 }
