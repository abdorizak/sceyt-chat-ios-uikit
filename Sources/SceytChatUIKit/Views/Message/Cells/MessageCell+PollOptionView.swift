//
//  MessageCell+PollOptionView.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 02.11.25.
//

import UIKit

extension MessageCell {
    open class PollOptionView: View, MessageCellMeasurable {
        
        // MARK: - UI Components
        open lazy var checkboxView = {
            $0.contentInsets = .zero
            return $0.withoutAutoresizingMask
        }(Components.checkBoxView.init())
        
        open lazy var optionLabel: UILabel = {
            let label = UILabel()
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
            label.textColor = .label
            label.textAlignment = .right
            return label.withoutAutoresizingMask
        }()
        
        open lazy var progressBar: UIProgressView = {
            let progress = UIProgressView(progressViewStyle: .default)
            progress.layer.cornerRadius = 3
            progress.clipsToBounds = true
            return progress.withoutAutoresizingMask
        }()
        
        private var optionLabelLeadingConstraint: NSLayoutConstraint?
        
        open var viewModel: PollOptionViewModel? {
            didSet {
                configure()
            }
        }

        open lazy var appearance: PollViewAppearance = Components.messageCell.appearance.pollViewAppearance {
            didSet {
                setupAppearance()
            }
        }
        
        // MARK: Setup
        
        open override func setup() {
            super.setup()
            addSubview(checkboxView)
            addSubview(optionLabel)
            addSubview(votersContainerView)
            votersContainerView.addSubview(votersStackView)
            votersContainerView.addSubview(voteCountLabel)
            addSubview(progressBar)
            
            let cornerRadius = appearance.progressBarCornerRadius
            progressBar.layer.cornerRadius = cornerRadius
            progressBar.clipsToBounds = true
            progressBar.subviews.forEach { subview in
                subview.layer.cornerRadius = cornerRadius
                subview.clipsToBounds = true
            }
        }
        
        open override func setupLayout() {
            checkboxView.leadingAnchor.pin(to: leadingAnchor)
            checkboxView.topAnchor.pin(to: topAnchor)
            checkboxView.resize(anchors: [.width(appearance.checkboxStyle.size), .height(appearance.checkboxStyle.size)])
            
            optionLabel.topAnchor.pin(to: topAnchor)
            optionLabelLeadingConstraint = optionLabel.leadingAnchor.pin(to: checkboxView.trailingAnchor, constant: 8.0)
            optionLabel.trailingAnchor.pin(to: votersContainerView.leadingAnchor, constant: -8.0)

            votersContainerView.trailingAnchor.pin(to: trailingAnchor)
            votersContainerView.topAnchor.pin(to: topAnchor)
            votersContainerView.widthAnchor.pin(constant: appearance.votersContainerWidth)
            votersContainerView.heightAnchor.pin(greaterThanOrEqualToConstant: appearance.voterAvatarStyle.size)

            votersStackView.centerYAnchor.pin(to: votersContainerView.centerYAnchor)
            votersStackView.trailingAnchor.pin(lessThanOrEqualTo: voteCountLabel.leadingAnchor, constant: -1.5)

            voteCountLabel.trailingAnchor.pin(to: votersContainerView.trailingAnchor)
            voteCountLabel.centerYAnchor.pin(to: votersContainerView.centerYAnchor)
            voteCountLabel.contentHuggingPriorityH(.required)

            progressBar.leadingAnchor.pin(to: optionLabel.leadingAnchor)
            progressBar.trailingAnchor.pin(to: trailingAnchor)
            progressBar.topAnchor.pin(to: optionLabel.bottomAnchor, constant: 8.0)
            progressBar.heightAnchor.pin(constant: appearance.progressBarHeight)
            progressBar.bottomAnchor.pin(to: bottomAnchor)
        }

        open override func setupAppearance() {
            super.setupAppearance()
            
            backgroundColor = .clear
            votersContainerView.backgroundColor = .clear
            
            optionLabel.font = appearance.optionTextStyle.font
            optionLabel.textColor = appearance.optionTextStyle.foregroundColor
            
            voteCountLabel.font = appearance.voteCountTextStyle.font
            voteCountLabel.textColor = appearance.voteCountTextStyle.foregroundColor

            progressBar.trackTintColor = appearance.progressBarForeground
            progressBar.progressTintColor = appearance.progressBarBackground
        }
        
        
        // MARK: Configuration
        
        func configure() {
            guard let viewModel else {
                return
            }

            voteCountLabel.text = String(viewModel.voteCount)
            optionLabel.text = viewModel.text
            progressBar.setProgress(viewModel.progress, animated: false)
            checkboxView.isSelected = viewModel.isSelected
            checkboxView.isHidden = viewModel.isClosed
            votersContainerView.isHidden = viewModel.isAnonymous

            // Update option label leading constraint when checkbox is hidden
            optionLabelLeadingConstraint?.isActive = false
            if viewModel.isClosed {
                optionLabelLeadingConstraint = optionLabel.leadingAnchor.pin(to: leadingAnchor)
            } else {
                optionLabelLeadingConstraint = optionLabel.leadingAnchor.pin(to: checkboxView.trailingAnchor, constant: 8.0)
            }

            votersStackView.removeArrangedSubviews()
            if !viewModel.isAnonymous {
                createVoterAvatars(voters: viewModel.voters, appearance: appearance)
            }
        }

        /// Update view model with animations
        func updateViewModel(_ newViewModel: PollOptionViewModel) {
            guard let oldViewModel = viewModel else {
                viewModel = newViewModel
                configure()
                return
            }

            let oldVoteCount = oldViewModel.voteCount
            let oldIsSelected = oldViewModel.isSelected

            // Animate vote count change with smooth transition
            if oldVoteCount != newViewModel.voteCount {
                let isIncreasing = newViewModel.voteCount > oldVoteCount
                let translationDistance: CGFloat = 12.0

                let exitTransform = CGAffineTransform(translationX: 0, y: isIncreasing ? -translationDistance : translationDistance)
                let enterTransform = CGAffineTransform(translationX: 0, y: isIncreasing ? translationDistance : -translationDistance)

                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                    self.voteCountLabel.transform = exitTransform
                    self.voteCountLabel.alpha = 0.0
                }) { _ in
                    self.voteCountLabel.text = String(newViewModel.voteCount)
                    self.voteCountLabel.transform = enterTransform
                    self.voteCountLabel.alpha = 0.0

                    UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [.curveEaseOut]) {
                        self.voteCountLabel.transform = .identity
                        self.voteCountLabel.alpha = 1.0
                    }
                    
                    self.viewModel = newViewModel
                }
            } else {
                voteCountLabel.text = String(newViewModel.voteCount)
                viewModel = newViewModel
            }

            // Animate progress bar with custom faster duration
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                self.progressBar.setProgress(newViewModel.progress, animated: false)
                self.progressBar.layoutIfNeeded()
            }

            votersStackView.removeArrangedSubviews()
            if !newViewModel.isAnonymous {
                createVoterAvatars(voters: newViewModel.voters, appearance: appearance)
            }
        }

        private func createVoterAvatars(voters: [ChatUser], appearance: PollViewAppearance) {
            votersStackView.spacing = appearance.voterAvatarStyle.spacing

            // Sort voters: current user first, then others
            guard let currentUserId = SceytChatUIKit.shared.currentUserId else {
                return
            }

            let sortedVoters = voters.sorted { voter1, voter2 in
                let isCurrent1 = voter1.id == currentUserId
                let isCurrent2 = voter2.id == currentUserId
                if isCurrent1 && !isCurrent2 {
                    return true
                } else if !isCurrent1 && isCurrent2 {
                    return false
                }
                return false
            }

            // Add voter avatars (limit to 3 for display)
            let avatarCount = min(sortedVoters.count, 3)
            let scale = UIScreen.main.traitCollection.displayScale
            let avatarSize = CGSize(
                width: appearance.voterAvatarStyle.size * scale,
                height: appearance.voterAvatarStyle.size * scale
            )

            let messageApperance = Components.messageCell.appearance
            let borderColor: UIColor = viewModel?.isIncoming == true ? messageApperance.incomingBubbleColor: messageApperance.outgoingBubbleColor
            for voter in sortedVoters.suffix(avatarCount) {
                let avatarView = SceytImageView()
                avatarView.contentMode = .scaleAspectFill
                avatarView.backgroundColor = .systemGray4
                avatarView.layer.cornerRadius = appearance.voterAvatarStyle.size / 2
                avatarView.layer.borderWidth = appearance.voterAvatarStyle.borderWidth
                avatarView.layer.borderColor = borderColor.cgColor
                avatarView.clipsToBounds = true
                avatarView.translatesAutoresizingMaskIntoConstraints = false
                avatarView.widthAnchor.constraint(equalToConstant: appearance.voterAvatarStyle.size).isActive = true
                avatarView.heightAnchor.constraint(equalToConstant: appearance.voterAvatarStyle.size).isActive = true

                // Get avatar appearance from user avatar provider
                let avatarRepresentation = SceytChatUIKit.shared.visualProviders.userAvatarProvider.provideVisual(for: voter)
                let initialsAppearance: InitialsBuilderAppearance? = {
                    if case .initialsAppearance(let appearance) = avatarRepresentation {
                        return appearance
                    }
                    return nil
                }()
                let defaultImage: UIImage? = {
                    if case .image(let image) = avatarRepresentation {
                        return image
                    }
                    return nil
                }()

                // Load avatar using AvatarBuilder
                _ = Components.avatarBuilder.loadAvatar(
                    into: avatarView,
                    for: voter,
                    appearance: initialsAppearance,
                    defaultImage: defaultImage,
                    size: avatarSize
                )
                
                votersStackView.addArrangedSubview(avatarView)
            }
        }
        
        // MARK: - Measurement
        
        open class func measure(
            model: MessageLayoutModel,
            appearance: MessageCell.Appearance
        ) -> CGSize {
            // This method is required by MessageCellMeasurable but not used directly
            // Use measure(option:appearance:maxWidth:) instead
            return .zero
        }
        
        open class func measure(
            option: PollOptionViewModel,
            appearance: PollViewAppearance,
            maxWidth: CGFloat,
            isClosed: Bool
        ) -> CGSize {
            let pollAppearance = appearance
            var height: CGFloat = 0
            
            // Checkbox height (if not closed)
            if !isClosed {
                height = max(height, pollAppearance.checkboxStyle.size)
            }
            
            // Calculate option text width
            // Available width: maxWidth - checkbox (if visible) - spacing - spacing - voters container
            let checkboxWidth: CGFloat = isClosed ? 0 : pollAppearance.checkboxStyle.size
            let spacingAfterCheckbox: CGFloat = 8.0
            let spacingBeforeVoters: CGFloat = 8.0
            let votersContainerWidth = pollAppearance.votersContainerWidth
            let availableTextWidth = maxWidth - checkboxWidth - spacingAfterCheckbox - spacingBeforeVoters - votersContainerWidth
            
            // Option text height
            let optionConfig = TextSizeMeasure.Config(
                restrictingWidth: availableTextWidth,
                maximumNumberOfLines: 0,
                font: pollAppearance.optionTextStyle.font,
                lastFragmentUsedRect: false
            )
            let optionTextSize = TextSizeMeasure.calculateSize(of: option.text, config: optionConfig).textSize
            let textHeight = ceil(optionTextSize.height)
            
            // Total option height: max of checkbox height or text height, plus spacing and progress bar
            let spacingBetweenTextAndProgress: CGFloat = 8.0
            let progressBarHeight = pollAppearance.progressBarHeight
            let minHeight = max(checkboxWidth > 0 ? pollAppearance.checkboxStyle.size : 0, textHeight) + spacingBetweenTextAndProgress + progressBarHeight
            
            // Use appearance optionMinHeight if available
            let finalHeight = max(minHeight, pollAppearance.optionMinHeight)
            
            return CGSize(width: maxWidth, height: finalHeight)
        }
    }
}
