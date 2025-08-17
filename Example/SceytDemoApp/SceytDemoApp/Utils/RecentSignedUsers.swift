//
//  RecentSignedUsers.swift
//  SceytChatUIKit
//
//  Created by Ovsep Keropian on 04.08.25.
//

import Foundation

struct RecentSignedUsers {
    
    private static let key = "RecentSignedUsersKey"
    private static let maxCount = 3

    static func addUser(id: String) {
        var current = UserDefaults.standard.array(forKey: key) as? [String] ?? []

        if let index = current.firstIndex(of: id) {
            current.append(current.remove(at: index))
        } else {
            current.append(id)
        }
        
        if current.count > maxCount {
            current.removeFirst() // remove oldest
        }

        UserDefaults.standard.set(current, forKey: key)
    }
    
    static func deleteUser(id: String) {
        var current = UserDefaults.standard.array(forKey: key) as? [String] ?? []

        current.removeAll(where: {$0 == id})
        
        UserDefaults.standard.set(current, forKey: key)
    }
    
    static var users: [String] {
        (UserDefaults.standard.array(forKey: key) as? [String] ?? []).reversed()
    }
}
