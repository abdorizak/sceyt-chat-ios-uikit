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
                
                // Check if message has poll data
                guard data.message.poll != nil else {
                    isHidden = true
                    return
                }

                isHidden = false
                configure(with: data)
            }
        }

        public var onDidTapOption: ((Int) -> Void)?

        override open func setup() {
            super.setup()

            layer.cornerRadius = 16
            optionsStackView.axis = .vertical
            optionsStackView.spacing = appearance.pollViewAppearance.optionSpacing
            separatorView.backgroundColor = .white
            questionLabel.numberOfLines = 0
            viewResultButton.setTitle("View Results", for: .normal)
            viewResultButton.setTitleColor(.systemBlue, for: .normal)
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
            backgroundColor = appearance.outgoingBubbleColor
        }

        private func configure(with layoutModel: MessageLayoutModel) {
            let message = layoutModel.message
            
            guard let poll = message.poll else {
                isHidden = true
                return
            }

            questionLabel.text = poll.name

            // Determine poll type text
            var pollTypeText = ""
            if poll.anonymous {
                pollTypeText += "Anonymous poll"
            } else {
                pollTypeText += "Public poll"
            }

            typeLabel.text = pollTypeText

            // Remove existing option views
            optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            optionViews.removeAll()

            // Calculate total votes
            let totalVotes = poll.votesPerOption.values.reduce(0, +)

            // Add option views
            for (index, option) in poll.options.enumerated() {
                let voteCount = poll.votesPerOption[option.id] ?? 0
                let pollOption = PollOption(
                    text: option.text,
                    votes: voteCount,
                    isSelected: option.selected,
                    progress: option.percentage(totalVotes: totalVotes)
                )

                let optionView = createOptionView(
                    option: pollOption,
                    index: index,
                    isSelected: option.selected,
                    totalVotes: totalVotes
                )

                optionsStackView.addArrangedSubview(optionView)
                optionViews[index] = optionView
            }
        }
        
        private func createOptionView(
            option: PollOption,
            index: Int,
            isSelected: Bool,
            totalVotes: Int
        ) -> PollOptionView {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            let optionView = PollOptionView()
            optionView.configure(with: option, appearance: appearance.pollViewAppearance)
            optionView.addGestureRecognizer(tapGesture)
            optionView.tag = index
            return optionView
        }

        @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
            guard let view = sender.view else { return }
            let pollOptionView = view as? PollOptionView
            pollOptionView?.checkboxView.isSelected.toggle()
            let index = view.tag
            onDidTapOption?(index)
        }

        /// Update the UI for a specific poll option optimistically
        open func updateOption(at index: Int, isSelected: Bool, voteCount: Int, totalVotes: Int) {
            guard let optionView = optionViews[index],
                  let data = data,
                  let poll = data.message.poll,
                  index >= 0 && index < poll.options.count else {
                return
            }
            
            let option = poll.options[index]
            let progress = option.percentage(totalVotes: totalVotes)
            
            // Update the option data
            let pollOption = PollOption(
                text: option.text,
                votes: voteCount,
                isSelected: isSelected,
                progress: progress
            )
            
            // Update the view
            optionView.configure(with: pollOption, appearance: appearance.pollViewAppearance)
        }

        /// Update all poll options with the latest data from the message
        open func refreshPollData() {
            guard let data = data else { return }
            configure(with: data)
        }

        private func parsePollData(from message: ChatMessage) -> PollData? {
            guard let poll = message.poll else { return nil }

            let totalVotes = poll.votesPerOption.values.reduce(0, +)
            let options = poll.options.map { option in
                let voteCount = poll.votesPerOption[option.id] ?? 0
                return PollOption(text: option.text, votes: voteCount, isSelected: option.selected, progress: option.percentage(totalVotes: totalVotes))
            }

            let selectedIndices = poll.options.enumerated().compactMap { index, option in
                option.selected ? index : nil
            }
            
            return PollData(
                question: poll.name,
                options: options,
                selectedOptions: selectedIndices,
                votedUsers: [],
                totalVotes: totalVotes
            )
        }

        open class func measure(
            model: MessageLayoutModel,
            appearance: MessageCell.Appearance
        ) -> CGSize {
            guard let pollData = PollView().parsePollData(from: model.message) else {
                return .zero
            }
            
            let pollAppearance = appearance.pollViewAppearance
            let maxWidth = Components.messageLayoutModel.defaults.messageWidth - 24 // padding
            let containerInsets = pollAppearance.containerInsets
            var height: CGFloat = containerInsets.top + containerInsets.bottom
            
            // Question height
            let questionFont = pollAppearance.questionTextStyle.font
            let questionSize = (pollData.question as NSString).boundingRect(
                with: CGSize(width: maxWidth - 24, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: questionFont],
                context: nil
            ).size
            height += ceil(questionSize.height) + pollAppearance.questionBottomSpacing
            
            // Options height
            let optionFont = pollAppearance.optionTextStyle.font
            for option in pollData.options {
                let optionSize = (option.text as NSString).boundingRect(
                    with: CGSize(width: maxWidth - 24 - 50, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: [.font: optionFont],
                    context: nil
                ).size
                height += max(ceil(optionSize.height) + 16, pollAppearance.optionMinHeight)
                height += pollAppearance.optionSpacing
            }
            
            // Footer height
            height += 20 + 12 // footer labels + spacing
            
            return CGSize(width: maxWidth, height: height)
        }
    }
    
    // MARK: - Poll Option View
       open class PollOptionView: View {
           
           // MARK: - UI Components
           open lazy var checkboxView = {
               $0.contentInsets = .zero
               return $0.withoutAutoresizingMask
           }(Components.checkBoxView.init())

           open lazy var optionLabel: UILabel = {
               let label = UILabel()
               label.font = .systemFont(ofSize: 16, weight: .regular)
               label.textColor = .label
               label.numberOfLines = 0
               label.lineBreakMode = .byWordWrapping
               return label.withoutAutoresizingMask
           }()

           open lazy var votersContainerView: UIView = {
               let view = UIView()
               return view.withoutAutoresizingMask
           }()

           open lazy var votersStackView: UIStackView = {
               let stack = UIStackView()
               stack.axis = .horizontal
               stack.distribution = .fillEqually
               stack.spacing = -8.0
               return stack.withoutAutoresizingMask
           }()

           open lazy var voteCountLabel: UILabel = {
               let label = UILabel()
               label.font = .systemFont(ofSize: 14, weight: .medium)
               label.textColor = .label
               label.textAlignment = .right
               return label.withoutAutoresizingMask
           }()

           open lazy var progressBar: UIProgressView = {
               let progress = UIProgressView(progressViewStyle: .default)
               progress.layer.cornerRadius = 3
               progress.clipsToBounds = true
               progress.layer.sublayers?.forEach { $0.cornerRadius = 3 }
               return progress.withoutAutoresizingMask
           }()

           // MARK: Setup

           open override func setup() {
               super.setup()
               addSubview(checkboxView)
               addSubview(optionLabel)
               addSubview(votersContainerView)
               votersContainerView.addSubview(votersStackView)
               votersContainerView.addSubview(voteCountLabel)
               addSubview(progressBar)
           }

           open override func setupLayout() {
               checkboxView.leadingAnchor.pin(to: leadingAnchor)
               checkboxView.topAnchor.pin(to: topAnchor)
               checkboxView.resize(anchors: [.width(20.0), .height(20.0)])

               optionLabel.topAnchor.pin(to: topAnchor)
               optionLabel.leadingAnchor.pin(to: checkboxView.trailingAnchor, constant: 8.0)
               optionLabel.trailingAnchor.pin(to: votersContainerView.leadingAnchor, constant: -8.0)

               votersContainerView.trailingAnchor.pin(to: trailingAnchor)
               votersContainerView.topAnchor.pin(to: topAnchor)
               votersContainerView.widthAnchor.pin(constant: 80.0)
               votersContainerView.heightAnchor.pin(greaterThanOrEqualToConstant: 20.0)

               votersStackView.centerYAnchor.pin(to: votersContainerView.centerYAnchor)
               votersStackView.trailingAnchor.pin(lessThanOrEqualTo: voteCountLabel.leadingAnchor, constant: -1.5)

               voteCountLabel.trailingAnchor.pin(to: votersContainerView.trailingAnchor)
               voteCountLabel.centerYAnchor.pin(to: votersContainerView.centerYAnchor)
               voteCountLabel.contentHuggingPriorityH(.required)

               progressBar.leadingAnchor.pin(to: optionLabel.leadingAnchor)
               progressBar.trailingAnchor.pin(to: trailingAnchor, constant: -8)
               progressBar.topAnchor.pin(to: optionLabel.bottomAnchor, constant: 8.0)
               progressBar.heightAnchor.pin(constant: 6.0)
               progressBar.bottomAnchor.pin(to: bottomAnchor)
           }

           open override func setupAppearance() {
               super.setupAppearance()
               backgroundColor = .clear
               votersContainerView.backgroundColor = .clear
           }

           // MARK: Configuration

           func configure(with data: MessageCell.PollView.PollOption, appearance: PollViewAppearance) {
               optionLabel.text = data.text
               optionLabel.font = appearance.optionTextStyle.font
               optionLabel.textColor = appearance.optionTextStyle.foregroundColor

               voteCountLabel.text = String(data.votes)
               voteCountLabel.font = appearance.voteCountTextStyle.font
               voteCountLabel.textColor = appearance.voteCountTextStyle.foregroundColor

               progressBar.progress = data.progress
               progressBar.trackTintColor = appearance.progressBarBackground
               progressBar.progressTintColor = appearance.progressBarForeground

               // Apply rounded corners to progress bar
               let cornerRadius = appearance.progressBarCornerRadius
               progressBar.layer.cornerRadius = cornerRadius
               progressBar.clipsToBounds = true
               progressBar.subviews.forEach { subview in
                   subview.layer.cornerRadius = cornerRadius
                   subview.clipsToBounds = true
               }

               // Set checkbox state
               checkboxView.isSelected = data.isSelected

               // Create voter avatars (mock data)
               createVoterAvatars(count: min(data.votes, 3), appearance: appearance)
           }

           private func createVoterAvatars(count: Int, appearance: PollViewAppearance) {
               votersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
               votersStackView.spacing = appearance.voterAvatarStyle.spacing

               for _ in 0..<count {
                   let avatarView = UIImageView()
                   avatarView.contentMode = .scaleAspectFill
                   avatarView.backgroundColor = .systemGray4
                   avatarView.layer.cornerRadius = appearance.voterAvatarStyle.size / 2
                   avatarView.layer.borderWidth = appearance.voterAvatarStyle.borderWidth
                   avatarView.layer.borderColor = appearance.voterAvatarStyle.borderColor.cgColor
                   avatarView.clipsToBounds = true
                   avatarView.translatesAutoresizingMaskIntoConstraints = false
                   avatarView.widthAnchor.constraint(equalToConstant: appearance.voterAvatarStyle.size).isActive = true
                   avatarView.heightAnchor.constraint(equalToConstant: appearance.voterAvatarStyle.size).isActive = true

                   votersStackView.addArrangedSubview(avatarView)
               }
           }
       }
}

// MARK: - Supporting Types

extension MessageCell.PollView {
    struct PollData {
        let question: String
        let options: [PollOption]
        let selectedOptions: [Int]
        let votedUsers: [String]
        let totalVotes: Int
    }
    
    struct PollOption {
        let text: String
        let votes: Int
        let isSelected: Bool
        let progress: Float
    }
}
