//
//  PollOptionDetailViewController.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit
import Combine

open class PollOptionDetailViewController: ViewController,
                                            UITableViewDelegate,
                                            UITableViewDataSource {

    open var viewModel: PollOptionDetailViewModel!
    private var subscriptions = Set<AnyCancellable>()

    open lazy var tableView = UITableView(frame: .zero, style: .grouped)
        .withoutAutoresizingMask
        .rowAutomaticDimension

    open override func setup() {
        super.setup()

        title = viewModel.option.optionText

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.register(PollResultsViewController.VoterCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        let footer = UIView()
        footer.frame.size.height = .leastNormalMagnitude
        tableView.tableFooterView = footer

        setupBindings()
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

        // Reload table when option changes
        viewModel.$option
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
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
        // Section 0: All voters only
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Show all voters
        return viewModel.numberOfVoters
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Voter cells
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PollResultsViewController.VoterCell.self)
        cell.parentAppearance = appearance.voterCellAppearance

        if let voter = viewModel.voter(at: indexPath.row) {
            cell.data = voter
        }

        return cell
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // All sections have minimal header
        return .leastNormalMagnitude
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // No headers needed
        return nil
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    open func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let cornerRadius = PollResultsViewController.Layouts.cellCornerRadius
        var corners: UIRectCorner = []

        if tableView.isFirst(indexPath) {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        if tableView.isLast(indexPath) {
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
            layer.borderWidth = PollResultsViewController.Layouts.cellSeparatorWidth

            // Calculate separator inset
            let separatorWidthInset: CGFloat = PollResultsViewController.Layouts.cellHorizontalPadding + 16

            layer.frame = CGRect(
                x: separatorWidthInset,
                y: cell.height - layer.borderWidth,
                width: cell.width - separatorWidthInset * 2,
                height: layer.borderWidth
            )
        }

        let maskLayer = CAShapeLayer()
        var rect = cell.bounds
        rect.origin.x = PollResultsViewController.Layouts.cellHorizontalPadding
        rect.size.width -= PollResultsViewController.Layouts.cellHorizontalPadding * 2
        maskLayer.path = UIBezierPath(roundedRect: rect,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }

    // MARK: Actions

    @objc open func closeTapped() {
        dismiss(animated: true)
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
