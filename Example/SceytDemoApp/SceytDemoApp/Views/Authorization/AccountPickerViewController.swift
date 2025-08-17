//
//  AccountPickerViewController.swift
//  SceytDemoApp
//
//  Created by Arthur Avagyan on 14.10.24
//  Copyright © 2024 Sceyt LLC. All rights reserved.
//

import UIKit
import SceytChatUIKit

class AccountPickerViewController: ViewController {
    
    // MARK: - Properties
    var onUserIdSelected: ((String) -> Void)?
    let userIds = Array(users.shuffled().prefix(5))
    let recentSignedInUsers = RecentSignedUsers.users
    
    // MARK: - Views
    lazy var titleLabel = {
        $0.text = "Select Account"
        $0.font = .systemFont(ofSize: .init(15), weight: .semibold)
        $0.textColor = SceytChatUIKit.shared.theme.colors.secondaryText
        return $0.withoutAutoresizingMask
    }(UILabel())
    
    lazy var tableView = {
        $0.dataSource = self
        $0.delegate = self
        $0.rowHeight = 56
        $0.estimatedRowHeight = 56
        $0.separatorStyle = .none
        $0.register(UITableViewCell.self)
        return $0.withoutAutoresizingMask
    }(UITableView())
    
    // MARK: - Lifecycle
    override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = .background
        tableView.backgroundColor = .clear
    }
    
    override func setupLayout() {
        super.setupLayout()
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        titleLabel.pin(to: view, anchors: [.leading(16), .top(20)])
        tableView.topAnchor.pin(to: titleLabel.bottomAnchor, constant: 12)
        tableView.pin(to: view, anchors: [.leading, .trailing, .bottom])
    }
}

extension AccountPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.cellForRow(at: indexPath)?.accessoryView = UIImageView(image: .radioSelected)
        var user: String {
            if indexPath.section == 0, !recentSignedInUsers.isEmpty {
                return recentSignedInUsers[indexPath.row]
            }
             return userIds[indexPath.row]
        }
        onUserIdSelected?(user)
        dismiss(animated: true)
    }
}

extension AccountPickerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        recentSignedInUsers.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, !recentSignedInUsers.isEmpty {
            return recentSignedInUsers.count
        }
         return userIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UITableViewCell.self)
        
        var user: String {
            if indexPath.section == 0, !recentSignedInUsers.isEmpty {
                return recentSignedInUsers[indexPath.row]
            }
             return userIds[indexPath.row]
        }
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = SceytChatUIKit.shared.theme.colors.surface1
        cell.selectedBackgroundView = bgColorView
        
        cell.backgroundColor = .clear
        cell.textLabel?.text = "@\(user)"
        cell.textLabel?.font = .systemFont(ofSize: .init(16), weight: .semibold)
        cell.textLabel?.textColor = SceytChatUIKit.shared.theme.colors.primaryText
        cell.imageView?.image = .defaultAvatar
        cell.accessoryView = UIImageView(image: .radio)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !recentSignedInUsers.isEmpty {
            if section == 0 {
                return "Recent Signed users"
            } else if section == 1 {
                return "All users"
            }
        }
        return nil
    }
}
