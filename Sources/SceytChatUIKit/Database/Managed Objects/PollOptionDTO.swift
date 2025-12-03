//
//  PollOptionDTO.swift
//  SceytChatUIKit
//
//  Created by Vahagn Manasyan on 28.10.25.
//  Copyright © 2025 Sceyt LLC. All rights reserved.
//

import Foundation
import CoreData
import SceytChat

@objc(PollOptionDTO)
public class PollOptionDTO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var poll: PollDTO?
    
    @nonobjc
    public static func fetchRequest() -> NSFetchRequest<PollOptionDTO> {
        return NSFetchRequest<PollOptionDTO>(entityName: entityName)
    }
    
    public static func fetch(
        id: String,
        pollId: String,
        context: NSManagedObjectContext
    ) -> PollOptionDTO? {
        let request = fetchRequest()
        request.predicate = .init(format: "id == %@ AND poll.id == %@", id, pollId)
        return fetch(request: request, context: context).first
    }
    
    public static func fetchOrCreate(
        id: String,
        pollId: String,
        context: NSManagedObjectContext
    ) -> PollOptionDTO {
        if let option = fetch(id: id, pollId: pollId, context: context) {
            return option
        }
        
        let mo = insertNewObject(into: context)
        mo.id = id
        return mo
    }
    
    public func map(_ option: SceytChat.PollOption) -> PollOptionDTO {
        id = option.id
        name = option.name
        return self
    }
}

extension PollOptionDTO: Identifiable { }

