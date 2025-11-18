//
//  PollVoteDTO.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 28.10.25.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import CoreData
import SceytChat

@objc(PollVoteDTO)
public class PollVoteDTO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var optionId: String
    @NSManaged public var createdAt: Int64
    @NSManaged public var user: UserDTO?
    @NSManaged public var pollDetails: PollDTO?
    @NSManaged public var ownPollDetails: PollDTO?
    
    @nonobjc
    public static func fetchRequest() -> NSFetchRequest<PollVoteDTO> {
        return NSFetchRequest<PollVoteDTO>(entityName: entityName)
    }
    
    public static func fetch(
        id: String,
        context: NSManagedObjectContext
    ) -> PollVoteDTO? {
        let request = fetchRequest()
        request.predicate = .init(format: "id == %@", id)
        return fetch(request: request, context: context).first
    }
    
    public static func fetch(
        optionId: String,
        userId: UserId,
        pollId: String,
        context: NSManagedObjectContext
    ) -> PollVoteDTO? {
        let request = fetchRequest()
        request.predicate = .init(format: "optionId == %@ AND user.id == %@ AND (pollDetails.id == %@ OR ownPollDetails.id == %@)", optionId, userId, pollId, pollId)
        return fetch(request: request, context: context).first
    }
    
    public static func fetchOrCreate(
        optionId: String,
        userId: UserId,
        pollId: String,
        context: NSManagedObjectContext
    ) -> PollVoteDTO {
        if let vote = fetch(optionId: optionId, userId: userId, pollId: pollId, context: context) {
            return vote
        }
        
        let mo = insertNewObject(into: context)
        mo.id = UUID().uuidString
        mo.optionId = optionId
        return mo
    }
    
    public func map(_ vote: SceytChat.PollVote) -> PollVoteDTO {
        optionId = vote.optionId
        createdAt = Int64(vote.createdAt.timeIntervalSince1970)
        return self
    }
}

extension PollVoteDTO: Identifiable { }

