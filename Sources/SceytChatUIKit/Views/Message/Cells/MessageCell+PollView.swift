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

                // Check if message has poll data
                guard data.message.poll != nil else {
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

            guard let poll = message.poll else {
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
            guard let poll = model.message.poll else {
                return .zero
            }

            let pollViewModel = PollViewModel(from: poll, isIncmoing: model.message.incoming)
            let pollAppearance = appearance.pollViewAppearance
            
            // Calculate max width using container insets
            let containerInsets = pollAppearance.containerInsets
            let contentMaxWidth = Components.messageLayoutModel.defaults.messageWidth - 24.0 // container left/right paddings
            var height: CGFloat = 0

            // Top padding from container insets
            height += containerInsets.top

            // Question height
            let questionConfig = TextSizeMeasure.Config(
                restrictingWidth: contentMaxWidth,
                maximumNumberOfLines: 0,
                font: pollAppearance.questionTextStyle.font,
                lastFragmentUsedRect: false
            )
            let questionSize = TextSizeMeasure.calculateSize(of: pollViewModel.question, config: questionConfig).textSize
            height += ceil(questionSize.height)

            // Type label height + spacing (using spacing between question and type)
            let typeLabelSpacing: CGFloat = 4.0 // Spacing between question and type label
            height += typeLabelSpacing
            let typeConfig = TextSizeMeasure.Config(
                restrictingWidth: contentMaxWidth,
                maximumNumberOfLines: 1,
                font: pollAppearance.pollTypeTextStyle.font,
                lastFragmentUsedRect: false
            )
            let typeSize = TextSizeMeasure.calculateSize(of: pollViewModel.pollTypeText, config: typeConfig).textSize
            height += ceil(typeSize.height)

            // Options height - use PollOptionView.measure for each option
            let optionSpacing = pollAppearance.optionSpacing

            for (index, option) in pollViewModel.options.enumerated() {
                let optionSize = PollOptionView.measure(
                    option: option,
                    appearance: pollAppearance,
                    maxWidth: contentMaxWidth,
                    isClosed: pollViewModel.closed
                )
                height += optionSize.height
                if index < pollViewModel.options.count - 1 {
                    height += optionSpacing
                }
            }

            // Separator + footer (if not anonymous)
            if !pollViewModel.anonymous {
                let separatorTopSpacing: CGFloat = 20.0 // Spacing before separator
                height += separatorTopSpacing
                let separatorHeight: CGFloat = 1.0 // Separator height
                height += separatorHeight
                // Button height: contentEdgeInsets (from setup: top: 16.0, bottom: 16.0) + intrinsic height
                let buttonTopInset: CGFloat = 16.0
                let buttonBottomInset: CGFloat = 16.0
                let buttonIntrinsicHeight: CGFloat = 16.0 // Approximate intrinsic height
                height += buttonTopInset + buttonBottomInset + buttonIntrinsicHeight
            }

            // Bottom padding from container insets
            height += containerInsets.bottom

            return CGSize(width: Components.messageLayoutModel.defaults.messageWidth, height: ceil(height))
        }
    }
 }
