//
//  CreatePollViewController.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit
import Combine

open class CreatePollViewController: ViewController,
                                      UITableViewDelegate,
                                      UITableViewDataSource {

    open var viewModel: CreatePollViewModel!
    private var subscriptions = Set<AnyCancellable>()

    open lazy var tableView = UITableView(frame: .zero, style: .grouped)
        .withoutAutoresizingMask
        .rowAutomaticDimension

    private lazy var questionHeaderLabel: UILabel = {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryText
        $0.numberOfLines = 0
        return $0.withoutAutoresizingMask
    }(UILabel())

    private lazy var optionsHeaderLabel: UILabel = {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryText
        $0.numberOfLines = 0
        return $0.withoutAutoresizingMask
    }(UILabel())

    private lazy var parametersHeaderLabel: UILabel = {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryText
        $0.numberOfLines = 0
        return $0.withoutAutoresizingMask
    }(UILabel())

    open override func setup() {
        super.setup()

        title = appearance.titleText
        questionHeaderLabel.text = appearance.questionDescriptionText
        optionsHeaderLabel.text = appearance.optionsHeaderText
        parametersHeaderLabel.text = appearance.parametersHeaderText

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.register(QuestionFieldCell.self)
        tableView.register(OptionFieldCell.self)
        tableView.register(SwitchOptionCell.self)
        tableView.register(AddOptionCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .interactive
        tableView.isEditing = true

        let footer = UIView()
        footer.frame.size.height = .leastNormalMagnitude
        tableView.tableFooterView = footer

        setupNavigationBarItems()
        setupBindings()
    }

    private func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: appearance.cancelText,
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: appearance.createText,
            style: .done,
            target: self,
            action: #selector(createTapped)
        )

        updateCreateButtonState()
    }

    private func setupBindings() {
        // Handle loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                loader.isLoading = isLoading
            }
            .store(in: &subscriptions)

        // Handle errors
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showAlert(error: error)
            }
            .store(in: &subscriptions)

        // Handle view model events
        viewModel.$event
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.onEvent(event)
            }
            .store(in: &subscriptions)

        // Handle poll changes to update create button
        viewModel.$poll
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateCreateButtonState()
            }
            .store(in: &subscriptions)
    }

    open override func setupLayout() {
        super.setupLayout()

        view.addSubview(tableView)
        tableView.pin(to: view.safeAreaLayoutGuide, anchors: [.leading, .trailing])
        tableView.pin(to: view, anchors: [.top, .bottom])
    }

    open override func setupAppearance() {
        super.setupAppearance()

        view.backgroundColor = appearance.backgroundColor
        tableView.backgroundColor = .clear
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { [weak self] _ in
            guard let self else { return }
            self.tableView.reloadData()
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let layoutAffectingChange =
            previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass ||
            previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass ||
            (previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false) ||
            previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory

        guard layoutAffectingChange else { return }

        tableView.reloadData()
    }

    // MARK: UITableViewDataSource

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Question field
        case 1: return viewModel.poll.options.count + 1 // Options
        case 2: return 3 // 3 switch cells for parameters
        default: return 0
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: QuestionFieldCell.self)
            cell.parentAppearance = appearance.questionFieldCellAppearance
            cell.textView.text = viewModel.poll.question
            cell.placeholderLabel.text = appearance.questionPlaceholderText
            cell.updatePlaceholderVisibility()
            cell.onTextChanged = { [weak self] text in
                self?.viewModel.updateQuestion(text)
            }
            cell.onHeightChanged = { [weak self] in
                self?.updateQuestionCellHeight()
            }
            return cell

        case 1:
            if indexPath.row < viewModel.poll.options.count {
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OptionFieldCell.self)
                cell.parentAppearance = appearance.optionFieldCellAppearance
                cell.textView.text = viewModel.poll.options[indexPath.row]
                cell.placeholderLabel.text = appearance.optionPlaceholderText(indexPath.row + 1)
                cell.updatePlaceholderVisibility()
                cell.onTextChanged = { [weak self] text in
                    self?.viewModel.updateOption(at: indexPath.row, value: text)
                }
                cell.onHeightChanged = { [weak self] in
                    self?.updateOptionCellHeight(at: indexPath)
                }
                cell.backgroundColor = CreatePollViewController.OptionFieldCell.appearance.containerBackgroundColor
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: AddOptionCell.self)
                cell.parentAppearance = appearance.addOptionCellAppearance
                cell.iconView.image = .messageActionMoreReactions
                cell.titleLabel.text = appearance.addOptionText
                
                return cell
            }

        case 2:
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SwitchOptionCell.self)
            cell.parentAppearance = appearance.switchOptionCellAppearance
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = appearance.allowMultipleAnswersText
                cell.switchControl.isOn = viewModel.poll.allowMultipleAnswers
                cell.onSwitchChanged = { [weak self] isOn in
                    self?.viewModel.updateAllowMultipleAnswers(isOn)
                }
            case 1:
                cell.titleLabel.text = appearance.showVoterNamesText
                cell.switchControl.isOn = viewModel.poll.showVoterNames
                cell.onSwitchChanged = { [weak self] isOn in
                    self?.viewModel.updateShowVoterNames(isOn)
                }
            case 2:
                cell.titleLabel.text = appearance.allowAddingOptionsText
                cell.switchControl.isOn = viewModel.poll.allowAddingOptions
                cell.onSwitchChanged = { [weak self] isOn in
                    self?.viewModel.updateAllowAddingOptions(isOn)
                }
            default:
                break
            }
            return cell

        default:
            return UITableViewCell()
        }
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 && indexPath.row == viewModel.poll.options.count {
            addOption()
        }
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1, 2:
            return UITableView.automaticDimension
        default:
            return .leastNormalMagnitude
        }
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1, 2:
            return 44
        default:
            return .leastNormalMagnitude
        }
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let padding = CreatePollViewController.Layouts.cellHorizontalPadding + 16
        switch section {
        case 0: // Question section
            let container = UIView()
            container.addSubview(questionHeaderLabel)
            questionHeaderLabel.pin(to: container, anchors: [.leading(padding), .trailing(-padding), .top(8), .bottom(-8)])
            return container
        case 1: // Options section
            let container = UIView()
            container.addSubview(optionsHeaderLabel)
            optionsHeaderLabel.pin(to: container, anchors: [.leading(padding), .trailing(-padding), .top(8), .bottom(-8)])
            return container
        case 2: // Parameters section
            let container = UIView()
            container.addSubview(parametersHeaderLabel)
            parametersHeaderLabel.pin(to: container, anchors: [.leading(padding), .trailing(-padding), .top(8), .bottom(-8)])
            return container
        default:
            return nil
        }
    }

    open func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let cornerRadius = Layouts.cellCornerRadius
        var corners: UIRectCorner = []

        if tableView.isFirst(indexPath) {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        if tableView.isLast(indexPath)
        {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
            cell.layer.sublayers?.first(where: { $0.name == "bottomBorder" })?.removeFromSuperlayer()
        } else {
            var layer: CALayer! = cell.layer.sublayers?.first(where: { $0.name == "bottomBorder" })
            if layer == nil {
                layer = CALayer()
                layer.name = "bottomBorder"
                cell.layer.addSublayer(layer)
            }
            layer.borderColor = appearance.separatorColor.cgColor
            layer.borderWidth = Layouts.cellSeparatorWidth
            layer.frame = CGRect(x: 0, y: cell.height - layer.borderWidth, width: cell.width, height: layer.borderWidth)
        }

        let maskLayer = CAShapeLayer()
        var rect = cell.bounds
        rect.origin.x = Layouts.cellHorizontalPadding
        rect.size.width -= Layouts.cellHorizontalPadding * 2
        maskLayer.path = UIBezierPath(roundedRect: rect,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }

    // MARK: - Reordering

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // Don't show delete button, only reorder control
        return .none
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        // Don't indent when editing (removes space for delete button)
        return false
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Only allow reordering for options section (not the "Add option" row)
        return indexPath.section == 1 && indexPath.row < viewModel.poll.options.count
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Only handle moves within the options section
        guard sourceIndexPath.section == 1 && destinationIndexPath.section == 1 else { return }

        // Don't allow moving to the "Add option" row
        let maxRow = viewModel.poll.options.count - 1
        let finalDestination = min(destinationIndexPath.row, maxRow)

        viewModel.moveOption(from: sourceIndexPath.row, to: finalDestination)
        
        self.tableView.reloadData()
//        if let cell = tableView.cellForRow(at: sourceIndexPath) {
//            self.tableView(tableView, willDisplay: cell, forRowAt: sourceIndexPath)
//        }
//        
//        if let cell = tableView.cellForRow(at: destinationIndexPath) {
//            self.tableView(tableView, willDisplay: cell, forRowAt: destinationIndexPath)
//        }
    }

    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // Prevent moving to other sections
        guard proposedDestinationIndexPath.section == 1 else {
            return sourceIndexPath
        }

        // Prevent moving to the "Add option" row
        if proposedDestinationIndexPath.row >= viewModel.poll.options.count {
            return IndexPath(row: viewModel.poll.options.count - 1, section: 1)
        }

        return proposedDestinationIndexPath
    }

    // MARK: Actions

    @objc open func cancelTapped() {
        dismiss(animated: true)
    }

    @objc open func createTapped() {
        guard viewModel.canCreatePoll else { return }
        // This will be handled by the parent/presenter
        dismiss(animated: true)
    }

    @objc open func addOption() {
        viewModel.addOption()
    }

    open func updateCreateButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.canCreatePoll
    }

    open func updateQuestionCellHeight() {
        let indexPath = IndexPath(row: 0, section: 0)

        // Get the current cell to preserve text view state
        guard let cell = tableView.cellForRow(at: indexPath) as? QuestionFieldCell else {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return
        }

        // Store the current selection range and text
        let selectedRange = cell.textView.selectedRange
        let isFirstResponder = cell.textView.isFirstResponder

        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()

            // Manually trigger willDisplay to update the mask layer
            if let cell = tableView.cellForRow(at: indexPath) {
                tableView(tableView, willDisplay: cell, forRowAt: indexPath)
            }
        }

        // Restore text view state
        if isFirstResponder {
            cell.textView.becomeFirstResponder()
            cell.textView.selectedRange = selectedRange
        }
    }

    open func updateOptionCellHeight(at indexPath: IndexPath) {
        // Get the current cell to preserve text view state
        guard let cell = tableView.cellForRow(at: indexPath) as? OptionFieldCell else {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return
        }

        // Store the current selection range and text
        let selectedRange = cell.textView.selectedRange
        let isFirstResponder = cell.textView.isFirstResponder

        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()

            // Manually trigger willDisplay to update the mask layer
            if let cell = tableView.cellForRow(at: indexPath) {
                tableView(tableView, willDisplay: cell, forRowAt: indexPath)
            }
        }

        // Restore text view state
        if isFirstResponder {
            cell.textView.becomeFirstResponder()
            cell.textView.selectedRange = selectedRange
        }
    }

    // MARK: - ViewModel Events

    open func onEvent(_ event: CreatePollViewModel.Event) {
        switch event {
        case .reloadData:
            tableView.reloadData()
        case .pollCreated:
            break
        }
    }
}

public extension CreatePollViewController {
    enum Layouts {
        public static var cellCornerRadius: CGFloat = 10
        public static var cellHorizontalPadding: CGFloat = 12
        public static var cellSeparatorWidth: CGFloat = 1
    }
}

private extension UITableView {
    func isFirst(_ indexPath: IndexPath) -> Bool {
        indexPath.item == 0
    }

    func isLast(_ indexPath: IndexPath) -> Bool {
        indexPath.item == numberOfRows(inSection: indexPath.section) - 1
    }
}
