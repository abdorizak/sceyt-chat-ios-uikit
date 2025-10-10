//
//  ChannelInviteLinkViewController.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import UIKit

open class ChannelInviteLinkViewController: ViewController,
                                            UITableViewDelegate,
                                            UITableViewDataSource {

    open var inviteLinkViewModel: ChannelInviteLinkViewModel!

    open lazy var router = Components.channelInviteLinkRouter
        .init(rootViewController: self)

    open lazy var tableView = UITableView(frame: .zero, style: .grouped)
        .withoutAutoresizingMask
        .rowAutomaticDimension
    
    private lazy var linkDescriptionLabel: UILabel = {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryText
        $0.numberOfLines = 0
        return $0.withoutAutoresizingMask
    }(UILabel())
    
    private lazy var messagesDescriptionLabel: UILabel = {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryText
        $0.numberOfLines = 0
        return $0.withoutAutoresizingMask
    }(UILabel())

    open override func setup() {
        super.setup()

        title = appearance.titleText
        linkDescriptionLabel.text = appearance.linkDescriptionText
        messagesDescriptionLabel.text = appearance.messagesDescriptionText

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.register(LinkFieldCell.self)
        tableView.register(ActionCell.self)
        tableView.register(SwitchOptionCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        let footer = UIView()
        footer.frame.size.height = .leastNormalMagnitude
        tableView.tableFooterView = footer
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

        // Only reload if something that actually affects row layout/appearance changed.
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
        case 0: return 1 // Link field
        case 1: return 1 // Show Previous Messages switch
        case 2: return inviteLinkViewModel.isPublicChannel ? 2 : 3 // Share, Reset Links (if private), Open QR Code
        default: return 0
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LinkFieldCell.self)
            cell.parentAppearance = appearance.linkFieldCellAppearance
            cell.linkLabel.text = inviteLinkViewModel.inviteLink
            cell.onCopy = { [weak self] in
                self?.copyLink()
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SwitchOptionCell.self)
            cell.parentAppearance = appearance.switchOptionCellAppearance
            cell.titleLabel.text = appearance.showPreviousMessagesText
            cell.switchControl.isOn = inviteLinkViewModel.showPreviousMessages
            cell.onSwitchChanged = { [weak self] isOn in
                self?.inviteLinkViewModel.showPreviousMessages = isOn
            }
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ActionCell.self)
            cell.parentAppearance = appearance.actionCellAppearance
            switch indexPath.row {
            case 0:
                cell.iconView.image = .chatShare
                cell.titleLabel.text = appearance.shareText
            case 1:
                if !inviteLinkViewModel.isPublicChannel {
                    cell.iconView.image = .refreshIcon
                    cell.titleLabel.text = appearance.resetLinkText
                } else {
                    cell.iconView.image = .channelProfileQR
                    cell.titleLabel.text = appearance.openQRCodeText
                }
            case 2:
                cell.iconView.image = .channelProfileQR
                cell.titleLabel.text = appearance.openQRCodeText
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

        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                shareLink()
            case 1:
                if !inviteLinkViewModel.isPublicChannel {
                    showResetLinkAlert()
                } else {
                    router.showQRCode()
                }
            case 2:
                router.showQRCode()
            default:
                break
            }
        }
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 16 : 24
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1: // Link field and Show Previous Messages sections
            return UITableView.automaticDimension
        default:
            return .leastNormalMagnitude
        }
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let padding = ChannelInviteLinkViewController.Layouts.cellHorizontalPadding + 16
        switch section {
        case 0: // Link field section
            let container = UIView()
            container.addSubview(linkDescriptionLabel)
            linkDescriptionLabel.pin(to: container, anchors: [.leading(padding), .trailing(-padding), .top(8), .bottom(0)])
            return container
        case 1: // Show Previous Messages section
            let container = UIView()
            container.addSubview(messagesDescriptionLabel)
            messagesDescriptionLabel.pin(to: container, anchors: [.leading(padding), .trailing(-padding), .top(8), .bottom(0)])
            return container
        default:
            return UIView()
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

    // MARK: Actions

    @objc open func copyLink() {
        UIPasteboard.general.string = inviteLinkViewModel.inviteLink
        showAlert(message: appearance.linkCopiedText)
    }

    @objc open func shareLink() {
        guard let link = inviteLinkViewModel.inviteLink else { return }
        let activityViewController = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    @objc open func showPreviousMessagesChanged(_ sender: UISwitch) {
        inviteLinkViewModel.showPreviousMessages = sender.isOn
    }
    
    @objc open func showResetLinkAlert() {
        let actions: [SheetAction] = [
            .init(
                title: appearance.cancelText,
                style: .cancel
            ),
            .init(
                title: appearance.resetText,
                style: .destructive,
                handler: { [weak self] in
                    self?.resetLink()
                }
            )
        ]
        
        showAlert(
            title: appearance.resetAlertTitleText,
            message: appearance.resetAlertMessageText,
            actions: actions,
            preferredActionIndex: 1
        )
    }
    
    @objc open func resetLink() {
        // TODO: Implement actual reset link functionality
        // This should call the appropriate method on inviteLinkViewModel
        print("Reset link functionality to be implemented")
    }
}

public extension ChannelInviteLinkViewController {
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
