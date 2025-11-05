//
//  PollDTO.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 28.10.25.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import CoreData
import SceytChat

@objc(PollDTO)
public class PollDTO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var pollDescription: String?
    @NSManaged public var anonymous: Bool
    @NSManaged public var allowMultipleVotes: Bool
    @NSManaged public var allowVoteRetract: Bool
    @NSManaged public var votesPerOption: NSDictionary?
    @NSManaged public var createdAt: Int64
    @NSManaged public var updatedAt: Int64
    @NSManaged public var closedAt: Int64
    @NSManaged public var closed: Bool
    @NSManaged public var messageTid: Int64
    @NSManaged public var message: MessageDTO?
    @NSManaged public var options: NSOrderedSet?
    @NSManaged public var votes: NSOrderedSet?
    @NSManaged public var ownVotes: NSOrderedSet?
    @NSManaged public var pendingVotes: NSSet?
    
    @nonobjc
    public static func fetchRequest() -> NSFetchRequest<PollDTO> {
        return NSFetchRequest<PollDTO>(entityName: entityName)
    }
    
    public static func fetch(
        id: String,
        context: NSManagedObjectContext
    ) -> PollDTO? {
        let request = fetchRequest()
        request.predicate = .init(format: "id == %@", id)
        return fetch(request: request, context: context).first
    }
    
    public static func fetch(
        messageTid: Int64,
        context: NSManagedObjectContext
    ) -> PollDTO? {
        let request = fetchRequest()
        request.predicate = .init(format: "messageTid == %lld", messageTid)
        return fetch(request: request, context: context).first
    }
    
    public static func fetchOrCreate(
        id: String,
        context: NSManagedObjectContext
    ) -> PollDTO {
        if let poll = fetch(id: id, context: context) {
            return poll
        }
        
        let mo = insertNewObject(into: context)
        mo.id = id
        return mo
    }
    
    public func map(_ poll: SceytChat.PollDetails) -> PollDTO {
        id = poll.id
        name = poll.name
        pollDescription = poll.description
        anonymous = poll.anonymous
        allowMultipleVotes = poll.allowMultipleVotes
        allowVoteRetract = poll.allowVoteRetract
        createdAt = Int64(poll.createdAt.timeIntervalSince1970)
        updatedAt = Int64(poll.updatedAt.timeIntervalSince1970)
        if let closedAt = poll.closedAt?.timeIntervalSince1970 {
            self.closedAt = Int64(closedAt)
        }
        closed = poll.closed
        
        // Convert votesPerOption map to NSDictionary
        if !poll.votesPerOption.isEmpty {
            var dict: [String: NSNumber] = [:]
            for (key, value) in poll.votesPerOption {
                dict[key] = value
            }
            votesPerOption = dict as NSDictionary
        } else {
            votesPerOption = [:]
        }
        
        return self
    }
}
