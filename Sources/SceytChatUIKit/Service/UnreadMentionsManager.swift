//
//  UnreadMentionsManager.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 29.07.25.
//

import SceytChat
import Foundation
import UIKit

// MARK: - UnreadMentionsManagerDelegate Protocol

public protocol UnreadMentionsManagerDelegate: AnyObject {
    func unreadMentionsManager(_ manager: UnreadMentionsManager, didReceiveNewMention message: Message)
    func unreadMentionsManager(_ manager: UnreadMentionsManager, didDeleteMention message: Message)
    func unreadMentionsManager(_ manager: UnreadMentionsManager, didEditMention message: Message, hadMentionBefore: Bool)
}

/// Service responsible for managing unread mentions: caching IDs and fetching new messages
public class UnreadMentionsManager: NSObject, ChannelDelegate {
    
    // MARK: - Properties
    
    private let channelId: ChannelId
    private let database: Database
    private var cachedUnreadMentionIds: [MessageId] = []
    private var currentIndex: Int = 0
    private var navigatedMentionIds: Set<MessageId> = []
    
    // Channel delegate identifier for registration
    private let channelDelegateIdentifier = UUID().uuidString
    
    // MARK: - Delegate
    
    public weak var delegate: UnreadMentionsManagerDelegate?

    // MARK: - Initialization

    public required init(channelId: ChannelId, database: Database = SceytChatUIKit.shared.database) {
        self.channelId = channelId
        self.database = database
        super.init()
        // Register as channel delegate to observe events
        SceytChatUIKit.shared.chatClient.add(
            channelDelegate: self,
            identifier: channelDelegateIdentifier
        )
    }

    deinit {
        // Unregister channel delegate
        SceytChatUIKit.shared.chatClient.removeChannelDelegate(identifier: channelDelegateIdentifier)
    }

    // MARK: - Public Methods

    /// Fetches the next unread mention message ID
    /// - Returns: The next unread mention message ID, or nil if none available
    public func getNextUnreadMentionId() async -> MessageId? {
        // If we have cached IDs, return the next one
        if !cachedUnreadMentionIds.isEmpty && currentIndex < cachedUnreadMentionIds.count {
            let messageId = cachedUnreadMentionIds[currentIndex]
            currentIndex += 1
            return messageId
        }
        
        // If no cached IDs or we've exhausted them, fetch new ones
        await refreshUnreadMentions()
        
        // Return the first ID from the refreshed cache
        if !cachedUnreadMentionIds.isEmpty {
            let messageId = cachedUnreadMentionIds[currentIndex]
            currentIndex += 1
            return messageId
        }
        
        return nil
    }

    /// Refreshes the cache by fetching unread mentions from the server
    public func refreshUnreadMentions() async {
        do {
            let query = UnreadMentionsListQuery.Builder(channelId: channelId)
                .limit(30)
                .build()

            let result = await query.loadNext()

            if let messages = result.1, !messages.isEmpty {
                // Cache the message IDs and sort them in ascending order (oldest first)
                // This ensures we navigate from old mentions to new ones
                cachedUnreadMentionIds = messages.map { UInt64($0) }.sorted()
                currentIndex = 0
                logger.debug("Cached \(messages.count) unread mention IDs in chronological order")
            } else {
                // Clear cache if no unread mentions
                cachedUnreadMentionIds.removeAll()
                currentIndex = 0
                logger.debug("No unread mentions found")
            }
        } catch {
            logger.error("Failed to fetch unread mentions: \(error)")
            // Clear cache on error
            cachedUnreadMentionIds.removeAll()
            currentIndex = 0
        }
    }
    
    /// Resets the cache and index
    public func reset() {
        cachedUnreadMentionIds.removeAll()
        currentIndex = 0
        navigatedMentionIds.removeAll()
    }
    
    /// Returns whether there are cached unread mentions available
    public var hasUnreadMentions: Bool {
        return currentIndex < cachedUnreadMentionIds.count
    }
    
    /// Returns the number of cached unread mentions remaining
    public var remainingUnreadMentionsCount: Int {
        return max(0, cachedUnreadMentionIds.count - currentIndex)
    }
    
    /// Marks a mention as navigated/seen by the user
    public func markMentionAsNavigated(_ messageId: MessageId) {
        navigatedMentionIds.insert(messageId)
    }
    
    /// Returns the count of navigated mentions that should be marked as read
    public var navigatedMentionsCount: Int {
        return navigatedMentionIds.count
    }

    /// Marks all navigated mentions as read on the server
    /// Returns the count of messages that were marked
    public func markNavigatedMentionsAsRead() -> Int {
        guard !navigatedMentionIds.isEmpty else { return 0 }

        // Convert to array for the API call
        let messageIds = Array(navigatedMentionIds)
        let count = messageIds.count

        // Clear navigated mentions after marking
        navigatedMentionIds.removeAll()

        logger.debug("Marked \(count) mentions as displayed locally")

        return count
    }
    
    /// Checks if all cached mentions have been navigated
    public var hasNavigatedAllCachedMentions: Bool {
        return currentIndex >= cachedUnreadMentionIds.count && !cachedUnreadMentionIds.isEmpty
    }
    
    /// Adds a new mention message ID to the cache (for real-time mentions)
    public func addNewMention(_ messageId: MessageId) {
        // Find the correct position to insert the new mention to maintain chronological order
        // Since we want oldest first, newer messages (higher IDs) should go towards the end
        let insertionIndex = cachedUnreadMentionIds.firstIndex(where: { $0 > messageId }) ?? cachedUnreadMentionIds.count
        
        // Insert at the correct position to maintain sorted order
        cachedUnreadMentionIds.insert(messageId, at: insertionIndex)
        
        // Adjust current index if the insertion happened before our current position
        if insertionIndex <= currentIndex {
            // Don't increment currentIndex as the user should still see this new mention
            // when they continue navigating
        }
        
        logger.debug("Added new mention to cache at position \(insertionIndex): \(messageId)")
    }
    
    /// Removes a mention message ID from the cache (for deleted mentions)
    public func removeMention(_ messageId: MessageId) {
        if let index = cachedUnreadMentionIds.firstIndex(of: messageId) {
            cachedUnreadMentionIds.remove(at: index)
            
            // Adjust current index if needed
            if index < currentIndex {
                currentIndex = max(0, currentIndex - 1)
            }
            
            // Also remove from navigated mentions if present
            navigatedMentionIds.remove(messageId)
            
            logger.debug("Removed mention from cache: \(messageId)")
        }
    }
    
    // MARK: - ChannelDelegate
    
    public func channel(_ channel: Channel, didReceive message: Message) {
        // Only handle messages for this specific channel
        guard channel.id == channelId else { return }
        
        handleNewMentionIfNeeded(message: message)
    }
    
    public func channel(_ channel: Channel, user: User, didEdit message: Message) {
        // Only handle messages for this specific channel
        guard channel.id == channelId else { return }
        
        handleEditedMentionIfNeeded(message: message)
    }
    
    public func channel(_ channel: Channel, user: User, didDelete message: Message) {
        // Only handle messages for this specific channel
        guard channel.id == channelId else { return }
        
        handleDeletedMentionIfNeeded(message: message)
    }
    
    // MARK: - Private Mention Event Handling
    
    /// Handles when a new message mentioning the current user is received
    private func handleNewMentionIfNeeded(message: Message) {
        // Check if this message mentions the current user
        guard message.incoming,
              message.mentionedUsers?.contains(where: { $0.id == SceytChatUIKit.shared.currentUserId }) == true
        else { return }

        // Update cache and notify delegate
        addNewMention(message.id)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.unreadMentionsManager(self, didReceiveNewMention: message)
        }
    }

    /// Handles when a message mentioning the current user is deleted
    private func handleDeletedMentionIfNeeded(message: Message) {
        var hadMentionBefore = false
        
        // Check if message had mention before deletion
        database.read { context in
            if let existingMessage = MessageDTO.fetch(id: message.id, context: context) {
                hadMentionBefore = existingMessage.mentionedUsers?.contains { $0.id == SceytChatUIKit.shared.currentUserId } == true
                logger.debug("Message \(message.id) deletion check: hadMentionBefore = \(hadMentionBefore)")
            }
        }
        
        // Only handle if message actually had mentions before deletion
        guard hadMentionBefore else { return }
        
        logger.debug("Handling deleted mention for message: \(message.id) in channel: \(message.channelId)")
        
        // Update cache and notify delegate
        removeMention(message.id)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.unreadMentionsManager(self, didDeleteMention: message)
        }
    }

    /// Handles when a message mentioning the current user is edited
    private func handleEditedMentionIfNeeded(message: Message) {
        var hadMentionBefore = false
        
        // Check if message had mention before edit
        database.read { context in
            if let existingMessage = MessageDTO.fetch(id: message.id, context: context) {
                hadMentionBefore = existingMessage.mentionedUsers?.contains { $0.id == SceytChatUIKit.shared.currentUserId } == true
                logger.debug("Message \(message.id) edit check: hadMentionBefore = \(hadMentionBefore)")
            }
        }
        
        // Check if mention status changed
        let hasMentionNow = message.mentionedUsers?.contains(where: { $0.id == SceytChatUIKit.shared.currentUserId }) == true

        logger.debug("Handling edited mention for message: \(message.id), hadBefore: \(hadMentionBefore), hasNow: \(hasMentionNow)")

        guard hadMentionBefore || hasMentionNow else {
            return
        }

        // Update cache based on mention status change
        if hadMentionBefore && !hasMentionNow {
            // Mention was removed
            removeMention(message.id)
        } else if !hadMentionBefore && hasMentionNow {
            // Mention was added
            addNewMention(message.id)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.unreadMentionsManager(self, didEditMention: message, hadMentionBefore: hadMentionBefore)
        }
    }
} 
