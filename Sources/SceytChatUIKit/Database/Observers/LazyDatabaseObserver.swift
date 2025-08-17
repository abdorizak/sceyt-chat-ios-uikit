//
//  LazyDatabaseObserver.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 14.03.23.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import Foundation
import CoreData

open class LazyDatabaseObserver<DTO: NSManagedObject, Item>: NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias CacheData = [[DTO]]
    private typealias Cache = Caches.CacheItems
    public let context: NSManagedObjectContext
    public let sortDescriptors: [NSSortDescriptor]
    public let itemCreator: (DTO) -> Item
    public let eventQueue: DispatchQueue
    public private(set) var fetchOffset: Int = 0
    public private(set) var fetchLimit: Int = 0
    public private(set) var currentFetchOffset: Int = 0
    public private(set) var fetchPredicate: NSPredicate
    public let sectionNameKeyPath: String?
    
    public var onWillChange: ((CacheData, ChangeItemPaths) -> Any?)?
    public var onDidChange: ((Bool, ChangeItemPaths, Any?) -> Void)?
    
    private let cacheQueue = DispatchQueue(label: "com.uikit.lazyDBO.access.cache", attributes: .concurrent)

    private final class Caches: Copyable {
        final class CacheItems: Copyable {
            @Atomic var cache = CacheData()
            @Atomic var mapItems = [NSManagedObjectID: Item]()
            @Atomic var mapDeletedItems = [NSManagedObjectID: Item]()
            
            func copy() -> CacheItems {
                let copy = CacheItems()
                copy.cache = cache
                copy.mapItems = mapItems
                copy.mapDeletedItems = mapDeletedItems
                return copy
            }
        }
        @Atomic var mainCache = CacheItems()
        @Atomic var workingCache = CacheItems()
        @Atomic var prevCache: CacheData?
        
        
        func copy() -> Caches {
            let c = Caches()
            c.mainCache = mainCache.copy()
            c.workingCache = workingCache.copy()
            c.prevCache = prevCache
            return c
        }
    }
    
    @Atomic private var mainCaches = Caches()
    @Atomic private var tmpCaches = Caches()
    private var currentCaches: Caches {
        isObserverRestarting ? tmpCaches : mainCaches
    }
    
    public let keyPaths: Set<RelationshipKeyPath>
    @Atomic private var updatedObjectIDs: Set<NSManagedObjectID> = []
    
    @Atomic public private(set) var isObserverStarted = false
    @Atomic public private(set) var isObserverPaused = false
    @Atomic private var isObserverRestarting = false
    
    public var viewContext: NSManagedObjectContext {
        SceytChatUIKit.shared.database.viewContext
    }
    
    private var lockContext: NSManagedObjectContext {
        Thread.isMainThread ? viewContext : context
    }
    
    
    public init(context: NSManagedObjectContext,
                         sortDescriptors: [NSSortDescriptor],
                         sectionNameKeyPath: String? = nil,
                         fetchPredicate: NSPredicate,
                         relationshipKeyPathsObserver: [String]? = nil,
                         itemCreator: @escaping (DTO) -> Item,
                         eventQueue: DispatchQueue = DispatchQueue.main) {
        self.context = context
        self.sortDescriptors = sortDescriptors
        self.fetchPredicate = fetchPredicate
        self.sectionNameKeyPath = sectionNameKeyPath
        self.itemCreator = itemCreator
        self.eventQueue = eventQueue
        if let keyPath = relationshipKeyPathsObserver {
            keyPaths = Set(keyPath.compactMap { keyPath in
                RelationshipKeyPath(keyPath: keyPath, relationships: DTO.entity().relationshipsByName)
            })
        } else {
            keyPaths = .init()
        }
    }
    
    open func startObserver(
        fetchOffset: Int = 0,
        fetchLimit: Int = 0,
        fetchPredicate: NSPredicate? = nil,
        completion: (() -> Void)? = nil
    ) {
        logger.debug("[MESS] STARTED")
            self.fetchPredicate = fetchPredicate ?? self.fetchPredicate
            self.fetchOffset = max(0, fetchOffset)
            self.fetchLimit = max(0, fetchLimit)
            self.currentFetchOffset = self.fetchOffset
            if let request = DTO.fetchRequest() as? NSFetchRequest<DTO> {
                var changeItems = [ChangeItem]()
                var changeSections = [ChangeSection]()
                request.sortDescriptors = sortDescriptors
                request.predicate = fetchPredicate ?? self.fetchPredicate
                request.fetchLimit = self.fetchLimit
                request.fetchOffset = self.fetchOffset
                
                context.perform {
                    logger.debug("[MESS] STARTED PERFORM")
                    self.clearCache()
                    var insertCache = self.mainCaches.workingCache
                    self.fetchObjects(context: self.context,
                                      request: request,
                                      in: insertCache,
                                      changeItems: &changeItems,
                                      changeSections: &changeSections)
                    self.isObserverStarted = true
                    self.mainCaches.workingCache = insertCache
                    let path = ChangeItemPaths(changeItems: changeItems, changeSections: changeSections)
                    let userInfo = self.onWillChange?(self.mainCaches.workingCache.cache, path)
                    self.queue {
                        logger.debug("[MESS] STARTED EVENT")
                        self.mainCaches.mainCache = insertCache
                        self.isObserverRestarting = false
                        self.onDidChange?(true, path, userInfo)
                        completion?()
                    }
                }
                addObservers()
            }
        }
    
    open func stopObserver() {
        isObserverStarted = false
        performAndWait { self.clearCache() }
        removeObservers()
    }
    
    open func pauseObserver() {
        isObserverPaused = true
    }
    
    open func resumeObserver() {
        isObserverPaused = false
    }
    
    open func restartObserver(
        fetchPredicate: NSPredicate,
        offset: Int? = nil,
        completion: (() -> Void)? = nil) {
            if isObserverRestarting {
                return
            }
            if isObserverStarted {
                tmpCaches = mainCaches.copy()
            }
            isObserverRestarting = true
            isObserverStarted = false
            removeObservers()
            self.fetchPredicate = fetchPredicate
            startObserver(
                fetchOffset: offset ?? fetchOffset,
                fetchLimit: fetchLimit,
                fetchPredicate: fetchPredicate,
                completion: completion
            )
        }
    
    open func update(predicate: NSPredicate, fetchOffset: Int = Int.max) {
        perform {
            self.fetchPredicate = predicate
            self.currentFetchOffset = max(0, fetchOffset == Int.max ? self.currentFetchOffset : fetchOffset)
        }
    }
    
    open var isEmpty: Bool {
        (isObserverStarted || isObserverRestarting) ? currentCaches.mainCache.cache.isEmpty : true
    }
    
    open var numberOfSections: Int {
        (isObserverStarted || isObserverRestarting) ? currentCaches.mainCache.cache.count : 0
    }
    
    open func numberOfItems(in section: Int) -> Int {
        if (isObserverStarted || isObserverRestarting), currentCaches.mainCache.cache.indices.contains(section) {
            debugPrint("[CACHE EVENT] numberOfItems", currentCaches.mainCache.cache[section].count)
            return currentCaches.mainCache.cache[section].count
        }
        return 0
    }
    
    open var count: Int {
        guard isObserverStarted || isObserverRestarting
        else { return 0 }
        var count = 0
        currentCaches.mainCache.cache.forEach {
            count += $0.count
        }
        return count
    }
    
    
    public func totalCountOfItems(predicate: NSPredicate? = nil) -> Int {
        let fetchRequest = DTO.fetchRequest()
        fetchRequest.predicate = predicate ?? fetchPredicate
        fetchRequest.includesSubentities = false
        let count = (try? lockContext.count(for: fetchRequest)) ?? 0
        return count
    }
    
    open func item(at indexPath: IndexPath) -> Item? {
        guard isObserverStarted || isObserverRestarting
        else { return nil }
        let caches = currentCaches
        guard caches.mainCache.cache.indices.contains(indexPath.section),
              caches.mainCache.cache[indexPath.section].indices.contains(indexPath.row)
        else {
            return nil
        }
        let dto = caches.mainCache.cache[indexPath.section][indexPath.row]
        
        if let item = _item(for: dto.objectID) {
            return item
        }
        return nil
    }
    
    public var firstItem: Item? {
        let indexPath = IndexPath(row: 0, section: 0)
        return item(at: indexPath)
    }
    
    public var lastItem: Item? {
        let caches = currentCaches
        guard let lastSection = caches.mainCache.cache.indices.last
        else { return nil }
        guard let lastRow = caches.mainCache.cache.last?.indices.last
        else { return nil }
        let indexPath = IndexPath(row: lastRow, section: lastSection)
        return item(at: indexPath)
    }
    
    open func workingCacheItem(at indexPath: IndexPath) -> Item? {
        guard isObserverStarted || isObserverRestarting
        else { return nil }
        let caches = isObserverStarted ? mainCaches : tmpCaches
        guard caches.workingCache.cache.indices.contains(indexPath.section),
              caches.workingCache.cache[indexPath.section].indices.contains(indexPath.row)
        else {
            return nil
        }
        let dto = caches.workingCache.cache[indexPath.section][indexPath.row]
        if let item = performAndWait({ caches.workingCache.mapItems[dto.objectID] ?? caches.workingCache.mapDeletedItems[dto.objectID] }) {
            return item
        }
        return nil
    }
    
    open func itemFromPrevCache(at indexPath: IndexPath) -> Item? {
        guard isObserverStarted || isObserverRestarting
        else { return nil }
        let caches = currentCaches
        guard let prevCache = caches.prevCache,
              prevCache.indices.contains(indexPath.section),
              prevCache[indexPath.section].indices.contains(indexPath.row)
        else { return nil }
        let dto = prevCache[indexPath.section][indexPath.row]
        if let item = performAndWait({caches.workingCache.mapItems[dto.objectID]}) {
            return item
        }
        return nil
    }
    
    open func items(
        at indexPaths: [IndexPath],
        completion: @escaping (([IndexPath: Item]) -> Void)) {
            context.perform {[weak self] in
                guard let self else { return }
                var items = [IndexPath: Item]()
                for indexPath in indexPaths {
                    if let item = self.item(at: indexPath) ?? self.itemFromPrevCache(at: indexPath) {
                        items[indexPath] = item
                    }
                }
                DispatchQueue.global().async {
                    completion(items)
                }
            }
        }
    
    open func item(for objectID: NSManagedObjectID) -> Item? {
        mappedItem(objectId: objectID)
    }
    
    private func _item(for objectID: NSManagedObjectID) -> Item? {
        mappedItem(objectId: objectID, cache: currentCaches)
    }
    
    public func indexPath(_ body: (Item) throws -> Bool) rethrows -> IndexPath? {
        let caches = currentCaches
        let _mapItem = caches.mainCache.mapItems
        for section in 0 ..< caches.mainCache.cache.count {
            for row in 0 ..< caches.mainCache.cache[section].count {
                let objectID = caches.mainCache.cache[section][row].objectID
                if let item = _mapItem[objectID] {
                    if try body(item) {
                        logger.debug("[LDBO] indexPath found row: \(row) section: \(section)")
                        return IndexPath(row: row, section: section)
                    }
                }
            }
        }
        return nil
    }
    
    public func forEach(_ body: (IndexPath, Item) throws -> Bool) rethrows {
        let caches = currentCaches
        let _mapItem = caches.mainCache.mapItems
        for section in 0 ..< caches.mainCache.cache.count {
            for row in 0 ..< caches.mainCache.cache[section].count {
                let objectID = caches.mainCache.cache[section][row].objectID
                if let item = _mapItem[objectID] {
                    let ip = IndexPath(row: row, section: section)
                    if try body(ip, item) {
                        return
                    }
                }
            }
        }
    }
    
    open func loadNext(
        predicate: NSPredicate? = nil,
        done: (() -> Void)? = nil
    ) {
        guard isObserverStarted else {
            done?()
            return
        }
        willChangeCache()
        currentFetchOffset += fetchLimit
        fetchAndUpdate(
            predicate: predicate,
            offset: currentFetchOffset,
            limit: fetchLimit)
        { count in

        } done: {
            done?()
        }
    }
    
    open func loadPrev(
        predicate: NSPredicate? = nil,
        done: (() -> Void)? = nil
    ) {
        guard isObserverStarted else {
            done?()
            return
        }
        willChangeCache()
        guard currentFetchOffset >= 0
        else {
            done?()
            return
        }
        currentFetchOffset = max(0, currentFetchOffset - fetchLimit)
        fetchAndUpdate(
            predicate: predicate,
            offset: currentFetchOffset,
            limit: fetchLimit)
        { count in

        } done: {
            done?()
        }
    }
    
    open func loadNear(
        predicate: NSPredicate? = nil,
        done: (() -> Void)? = nil
    ) {
        guard isObserverStarted else {
            done?()
            return
        }
        willChangeCache()
        let minOffset = min(currentFetchOffset, fetchLimit / 2)
        currentFetchOffset = max(0, currentFetchOffset - minOffset)
        fetchAndUpdate(
            predicate: predicate,
            offset: currentFetchOffset,
            limit: fetchLimit,
            fetched: { count in
                
            },
            done: {
                done?()
            }
        )
    }
    
    open func makeFetchBuilder() -> FetchBuilder {
        FetchBuilder(ldo: self)
    }
    
    open func load(
        from offset: Int,
        limit: Int,
        predicate: NSPredicate? = nil,
        done: (() -> Void)? = nil
    ) {
        willChangeCache()
        fetchAndUpdate(
            predicate: predicate,
            offset: offset,
            limit: limit
        ) { _ in
            
        } done: {
            done?()
        }
    }
    
    open func loadAll(
        from offset: Int,
        limit: Int,
        predicate: NSPredicate? = nil,
        done: (() -> Void)? = nil
    ) {
        guard isObserverStarted else {
            done?()
            return
        }
        currentFetchOffset = offset
        load(
            from: offset,
            limit: limit,
            predicate: predicate,
            done: done
        )
    }
    
    open func deleteCache(after indexPath: IndexPath) {
        self.perform {[weak self] in
            guard let self = self else { return }
            var insertCache = mainCaches.workingCache
            var changeItems = [ChangeItem]()
            var changeSections = [ChangeSection]()
            var deletedIndexPaths: [IndexPath] = []
            var toDeleteteIds: [NSManagedObjectID] = []
            if indexPath.section < insertCache.cache.count {
                let sectionObjects = insertCache.cache[indexPath.section]
                if indexPath.row + 1 < sectionObjects.count {
                    for row in (indexPath.row + 1) ..< sectionObjects.count {
                        let object = insertCache.cache[indexPath.section][row]
                        toDeleteteIds.append(object.objectID)
                        if let m = object as? MessageDTO {
                            debugPrint(
                                "[EVENT] Deleting object3:",
                                m.body.prefix(10),
                                "at",
                                IndexPath(row: row, section: indexPath.section)
                            )
                        }
                        changeItems.append(.delete(IndexPath(row: row, section: indexPath.section)))
                        deletedIndexPaths.append(IndexPath(row: row, section: indexPath.section))
                    }
                    insertCache
                        .cache[indexPath.section]
                        .removeSubrange(
                            (indexPath.row + 1) ..< sectionObjects.count
                        )
                }
            }

            if indexPath.section + 1 < insertCache.cache.count {
                for section in (indexPath.section + 1) ..< insertCache.cache.count {
                    for row in 0..<insertCache.cache[section].count {
                        let object = insertCache.cache[section][row]
                        toDeleteteIds.append(object.objectID)
                        if let m = object as? MessageDTO {
                            debugPrint(
                                "[EVENT] Deleting object4:",
                                m.body.prefix(10),
                                "at",
                                IndexPath(row: row, section: section)
                            )
                        }
                        deletedIndexPaths.append(IndexPath(row: row, section: section))
                    }
                    changeSections.append(.delete(section))
                }
                insertCache.cache.removeSubrange((indexPath.section + 1) ..< insertCache.cache.count)
            }
            toDeleteteIds.forEach {
                insertCache.mapItems[$0] = nil
                insertCache.mapDeletedItems[$0] = nil
            }
            debugPrint("[EVENT] CACHE DELETED AFTER INDEX PATHS: \(deletedIndexPaths.count)")
            
            let paths = ChangeItemPaths(
                changeItems: changeItems,
                changeSections: changeSections
            )
            didUpdate(
                insertCache: insertCache,
                paths: paths,
                done: nil
            )
        }
        
    }
    
    open func deleteCache(before indexPath: IndexPath) {
        self.perform {[weak self] in
            guard let self = self else { return }
            var insertCache = mainCaches.workingCache
            var changeItems = [ChangeItem]()
            var changeSections = [ChangeSection]()
            var deletedIndexPaths: [IndexPath] = []
            var toDeleteteIds: [NSManagedObjectID] = []
            if indexPath.section > 0 {
                for section in 0 ..< indexPath.section {
                    for row in 0 ..< insertCache.cache[section].count {
                        let object = insertCache.cache[section][row]
                        toDeleteteIds.append(object.objectID)
                        if let m = object as? MessageDTO {
                            print(
                                "[EVENT] Deleting object1:",
                                m.body.prefix(10),
                                "at",
                                IndexPath(row: row, section: section)
                            )
                        }
                                 
                        changeItems.append(.delete(IndexPath(row: row, section: indexPath.section)))
                        deletedIndexPaths.append(IndexPath(row: row, section: section))
                    }
                    changeSections.append(.delete(section))
                }
                insertCache.cache.removeSubrange(0 ..< indexPath.section)
            }

            let adjustedSection = max(0, indexPath.section - (deletedIndexPaths.last.map { $0.section + 1 } ?? 0))

            if adjustedSection < insertCache.cache.count {
                if indexPath.row > 0 && indexPath.row <= insertCache.cache[adjustedSection].count {
                    for row in 0 ..< indexPath.row {
                        let object = insertCache.cache[adjustedSection][row]
                        toDeleteteIds.append(object.objectID)
                        if let m = object as? MessageDTO {
                            debugPrint(
                                "[EVENT] Deleting object2:",
                                m.body.prefix(10),
                                "at",
                                IndexPath(row: row, section: adjustedSection)
                            )
                        }
                        deletedIndexPaths.append(IndexPath(row: row, section: adjustedSection))
                        changeItems.append(.delete(IndexPath(row: row, section: indexPath.section)))
                    }
                    insertCache.cache[adjustedSection].removeSubrange( 0 ..< indexPath.row)
                }
            }
            toDeleteteIds.forEach {
                insertCache.mapItems[$0] = nil
                insertCache.mapDeletedItems[$0] = nil
            }
            debugPrint("[EVENT] CACHE DELETED BEFORE INDEX PATHS: \(deletedIndexPaths.count)")
            
            let paths = ChangeItemPaths(
                changeItems: changeItems,
                changeSections: changeSections
            )
            didUpdate(
                insertCache: insertCache,
                paths: paths,
                done: nil
            )
        }
    }
    
    private func fetchAndUpdate(
        predicate: NSPredicate?,
        offset: Int,
        limit: Int,
        fetched: @escaping (Int) -> Void,
        done: (() -> Void)? = nil
    ) {
        func perform(context: NSManagedObjectContext) {
            if let request = DTO.fetchRequest() as? NSFetchRequest<DTO> {
                var insertCache = mainCaches.workingCache
                var changeItems = [ChangeItem]()
                var changeSections = [ChangeSection]()
                request.sortDescriptors = sortDescriptors
                request.predicate = predicate ?? fetchPredicate
                request.fetchLimit = limit
                request.fetchOffset = offset
                let count = fetchObjects(context: context,
                                         request: request,
                                         in: insertCache,
                                         changeItems: &changeItems,
                                         changeSections: &changeSections).count
                fetched(count)
                didUpdate(
                    insertCache: insertCache,
                    paths: ChangeItemPaths(
                        changeItems: changeItems,
                        changeSections: changeSections),
                    done: done)
            }
        }
        
        self.perform {
            perform(context: self.context)
        }
    }
    
    private func fetchAndUpdate(requests: [FetchBuilder.Request],
        done: ((ChangeItemPaths) -> Void)? = nil
    ) {
        func perform(context: NSManagedObjectContext) {
            var insertCache = mainCaches.workingCache
            var changeItems = [ChangeItem]()
            var changeSections = [ChangeSection]()
            requests.forEach { request in
                guard let fetchRequest = request.fetchRequest else { return }
                fetchObjects(context: context,
                                         request: fetchRequest,
                                         in: insertCache,
                                         changeItems: &changeItems,
                                         changeSections: &changeSections,
                             reverse: request.reversed)
            }
            
            let path = ChangeItemPaths(
                changeItems: changeItems,
                changeSections: changeSections
            )
            didUpdate(
                insertCache: insertCache,
                paths: path,
                done: {
                    done?(path)
                })
        }
        
        self.perform {
            perform(context: self.context)
        }
    }
    
    
    @objc
    open func willSaveObjects(notification: Notification) {
        guard isObserverStarted else { return }
    }
    
    @objc
    open func didSaveObjects(notification: Notification) {
        guard isObserverStarted, !isObserverPaused else { return }
        guard !updatedObjectIDs.isEmpty else { return }
        guard notification.userInfo != nil
        else { return }
        debugPrint("[MESSAGE STORE] didSaveObjects", notification.userInfo?.keys)
        let objIDs = updatedObjectIDs
        updatedObjectIDs.removeAll()
        context.perform {[weak self] in
            guard let self else { return }
            for id in objIDs {
                if let obj = self.context.registeredObject(for: id) {
                    self.context.refresh(obj, mergeChanges: true)
                }
            }
        }
    }
    
    @objc
    open func didChangeObjects(notification: Notification) {
        guard isObserverStarted, !isObserverPaused else { return }
        guard let userInfo = notification.userInfo
        else { return }
        debugPrint("[MESSAGE STORE] didChangeObjects", notification.userInfo?.keys)
        if let currentContext = notification.object as? NSManagedObjectContext,
           (currentContext === context) {
            
            func perform() {
                logger.verbose("[MESSAGE SEND] didChangeObjects perform")
                var sendEvent = false
                var changeItems = [ChangeItem]()
                var changeSections = [ChangeSection]()
                var insertCache = mainCaches.workingCache
                var shouldInsert: [DTO]?
                if let objs = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
                    let dtos = sorted(objs)
                    if !dtos.isEmpty {
                        willChangeCache()
                        insert(dtos: dtos, in: insertCache, changeItems: &changeItems, changeSections: &changeSections)
                        sendEvent = true
                    }
                }
                if let objs = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject> {
                    let dtos = sorted(objs)
                    if !dtos.isEmpty {
                        willChangeCache()
                        shouldInsert = reload(dtos: dtos, in: insertCache, changeItems: &changeItems, changeSections: &changeSections)
                        sendEvent = true
                    }
                }
                
                if let objs = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
                    let dtos = sorted(objs)
                    if !dtos.isEmpty {
                        willChangeCache()
                        delete(dtos: dtos, in: insertCache, changeItems: &changeItems, changeSections: &changeSections)
                        sendEvent = true
                    }
                }
                mainCaches.workingCache = insertCache
                if sendEvent {
                    if !changeItems.isEmpty || !changeSections.isEmpty {
                        didUpdate(
                            insertCache: insertCache,
                            paths: ChangeItemPaths(
                                changeItems: changeItems,
                                changeSections: changeSections),
                            done: nil)
                    }
                    
                    
                    if let dtos = shouldInsert,
                       !dtos.isEmpty {
                        var changeItems = [ChangeItem]()
                        var changeSections = [ChangeSection]()
                        var insertCache = mainCaches.workingCache
                        if !dtos.isEmpty {
                            willChangeCache()
                            insert(dtos: dtos, in: insertCache, changeItems: &changeItems, changeSections: &changeSections)
                            didUpdate(
                                insertCache: insertCache,
                                paths: ChangeItemPaths(
                                    changeItems: changeItems,
                                    changeSections: changeSections),
                                done: nil)
                        }
                    }
                }
            }
            
            currentContext.perform {
                perform()
            }
        }
        
        if let objs = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
           let updatedObjectIDs = objs.updatedObjectIDs(for: keyPaths),
           !updatedObjectIDs.isEmpty {
            self.updatedObjectIDs = self.updatedObjectIDs.union(updatedObjectIDs)
        }
    }
}

private extension LazyDatabaseObserver {
    
    private func compareSectionObjects(lhs: Any, rhs: Any) -> ComparisonResult {
        
        func sort(lhs: Any, rhs: Any) -> ComparisonResult {
            if let l = lhs as? NSNumber,
               let r = rhs as? NSNumber {
                return l.compare(r)
            }
            
            if let l = lhs as? NSString,
               let r = rhs as? NSString {
                return l.compare(r as String)
            }
            logger.error("not implemented Comparison for \(lhs) and \(rhs)")
            return .orderedSame
        }
        for sortDescriptor in sortDescriptors {
            let result: ComparisonResult
            if sortDescriptor.ascending {
                result = sort(lhs: lhs, rhs: rhs)
            } else {
                result = sort(lhs: rhs, rhs: lhs)
            }
            if result == .orderedSame {
                continue
            } else {
                return result
            }
            
        }
        return .orderedSame
        
        
    }
    
    private func insert(
        dto: DTO,
        section: Int,
        in cache: Cache,
        changeItems: inout [ChangeItem]
    ) {
        var sds = sortDescriptors
        var sort = sds.removeFirst()
        var foundIndex = 0
        exitLoop: for (index, element) in cache.cache[section].enumerated() {
        var canContinue = false
        repeat {
            canContinue = false
            let compare = sort.compare(dto, to: element)
            switch compare {
            case .orderedAscending:
                foundIndex = index
                break exitLoop
            case .orderedDescending:
                foundIndex = index + 1
                continue
            case .orderedSame:
                if !sds.isEmpty {
                    sort = sds.removeFirst()
                    canContinue = true
                } else {
                    break exitLoop
                }
            }
        } while(canContinue)
        sds = sortDescriptors
        sort = sds.removeFirst()
    }
        let item = itemCreator(dto)
        cache.cache[section].insert(dto, at: foundIndex)
        cache.mapItems[dto.objectID] = item
        cache.mapDeletedItems[dto.objectID] = nil
        changeItems.append(.insert(.init(row: foundIndex, section: section), item))
    }
    
    @discardableResult
    private func fetchObjects(
        context: NSManagedObjectContext,
        request: NSFetchRequest<DTO>,
        in cache: Cache,
        changeItems: inout [ChangeItem],
        changeSections: inout [ChangeSection],
        reverse: Bool = false
    ) -> [DTO] {
        let startTime = CFAbsoluteTimeGetCurrent()
        let dtos = DTO.fetch(request: request, context: context)
        insert(
            dtos: reverse ? dtos.reversed() : dtos,
            in: cache,
            changeItems: &changeItems,
            changeSections: &changeSections
        )
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        logger.verbose("[PERFORMANCE] fetch data time elapsed \(timeElapsed) s.")
        return dtos
    }
    
    private func insert(
        dtos: [DTO],
        in cache: Cache,
        changeItems: inout [ChangeItem],
        changeSections: inout [ChangeSection]
    ) {
        var valueCache = [NSManagedObjectID: Any]()
        for dto in dtos {
            guard !hasMapped(objectId: dto.objectID, cache: cache)
            else {
                if let m = dto as? MessageDTO {
                    debugPrint(
                        "[EVENT] INSERT MESSAGE CANCELED DTO",
                        m.body.prefix(10),
                        m.id,
                        m.unlisted
                    )
                }
                continue
            }
            if let m = dto as? MessageDTO {
                debugPrint(
                    "[EVENT] INSERT MESSAGE DTO",
                    m.body.prefix(10),
                    m.id,
                    m.unlisted
                )
            }
            if cache.cache.isEmpty {
                cache.cache.append([dto])
                let item = itemCreator(dto)
                cache.mapItems[dto.objectID] = item
                cache.mapDeletedItems[dto.objectID] = nil
                changeSections.append(.insert(0))
                changeItems.append(.insert(.init(row: 0, section: 0), item))
            } else if let sectionNameKeyPath {
                var found = false
                let _nv = dto.value(forKey: sectionNameKeyPath)
                exitLoop: for (index, elements) in cache.cache.enumerated() {
                if let first = elements.first {
                    if let fv = valueCache[first.objectID] ?? first.value(forKey: sectionNameKeyPath),
                       let nv = _nv {
                        valueCache[first.objectID] = fv
                        switch compareSectionObjects(lhs: fv, rhs: nv) {
                        case .orderedSame:
                            insert(dto: dto, section: index, in: cache, changeItems: &changeItems)
                            found = true
                            break exitLoop
                        case .orderedDescending:
                            let item = itemCreator(dto)
                            cache.mapItems[dto.objectID] = item
                            cache.mapDeletedItems[dto.objectID] = nil
                            cache.cache.insert([dto], at: index)
                            for (row, changeItem) in changeItems.enumerated() where changeItem.indexPath.section >= index {
                                var indexPath = changeItem.indexPath
                                indexPath.section += 1
                                switch changeItem {
                                case let .insert(ip, item):
                                    changeItems[row] = .insert(IndexPath(row: ip.row, section: ip.section + 1), item)
                                case let .delete(ip):
                                    changeItems[row] = .delete(IndexPath(row: ip.row, section: ip.section + 1))
                                case let .update(ip, item):
                                    changeItems[row] = .update(IndexPath(row: ip.row, section: ip.section + 1), item)
                                case let .move(fip, tip, item):
                                    changeItems[row] = .move(IndexPath(row: fip.row, section: fip.section + 1),
                                                             IndexPath(row: tip.row, section: tip.section + 1), item)
                                }
                            }
                            changeSections.append(.insert(index))
                            changeItems.append(.insert(.init(row: 0, section: index), item))
                            found = true
                            break exitLoop
                        case .orderedAscending:
                            continue
                        }
                    }
                }
            }
                if !found {
                    cache.cache.append([dto])
                    let item = itemCreator(dto)
                    cache.mapItems[dto.objectID] = item
                    cache.mapDeletedItems[dto.objectID] = nil
                    changeSections.append(.insert(cache.cache.count - 1))
                    changeItems.append(.insert(.init(row: 0, section: cache.cache.count - 1), item))
                }
            } else {
                insert(dto: dto, section: 0, in: cache, changeItems: &changeItems)
            }
        }
    }
    
    private func reload(
        dtos: [DTO],
        in cache: Cache,
        changeItems: inout [ChangeItem],
        changeSections: inout [ChangeSection]
    ) -> [DTO] {
        var shouldInsert = [DTO]()
        for dto in dtos {
            if !reload(dto: dto, in: cache, changeItems: &changeItems, changeSections: &changeSections) {
                shouldInsert.append(dto)
            }
        }
        return shouldInsert
    }
    
    private func reload(
        dto: DTO,
        in cache: Cache,
        changeItems: inout [ChangeItem],
        changeSections: inout [ChangeSection]
    ) -> Bool {
        
        var foundIndexPath: IndexPath?
        
        for (section, objects) in cache.cache.enumerated() {
            if foundIndexPath != nil {
                break
            }
            for (row, item) in objects.enumerated() {
                if item.objectID == dto.objectID {
                    foundIndexPath = IndexPath(row: row, section: section)
                    break
                }
            }
        }
        var isRemovedSection = false
        
        if let foundIndexPath {
            let beforeCount = cache.cache.count
            cache.cache[foundIndexPath.section].remove(at: foundIndexPath.row)
            if cache.cache[foundIndexPath.section].isEmpty {
                cache.cache.remove(at: foundIndexPath.section)
                isRemovedSection = true
            }
            cache.mapDeletedItems[dto.objectID] = cache.mapItems[dto.objectID]
            cache.mapItems[dto.objectID] = nil
            var _changeItems = [ChangeItem]()
            var _changeSections = [ChangeSection]()
            
            insert(dtos: [dto], in: cache, changeItems: &_changeItems, changeSections: &_changeSections)
            
            guard let item = _changeItems.last else { return false}
            if cache.cache.count == beforeCount {
                if isRemovedSection {
                    if item.indexPath.section == foundIndexPath.section {
                        if item.indexPath.row == foundIndexPath.row {
                            changeItems.append(.update(item.indexPath, item.item!))
                        } else {
                            changeItems.append(.move(foundIndexPath, item.indexPath, item.item!))
                        }
                    } else {
                        changeSections.append(.delete(foundIndexPath.section))
                        changeSections.append(.insert(item.indexPath.section))
                        changeItems.append(.move(foundIndexPath, item.indexPath, item.item!))
                    }
                } else {
                    if item.indexPath.section == foundIndexPath.section {
                        if item.indexPath.row == foundIndexPath.row {
                            changeItems.append(.update(item.indexPath, item.item!))
                        } else {
                            changeItems.append(.move(foundIndexPath, item.indexPath, item.item!))
                        }
                    } else {
                        changeItems.append(.move(foundIndexPath, item.indexPath, item.item!))
                    }
                }
            } else if cache.cache.count > beforeCount {
                if cache.cache[item.indexPath.section].count == 1 {
                    changeItems.append(.move(foundIndexPath, item.indexPath, item.item!))
                    changeSections.append(.insert(item.indexPath.section))
                } else {
                    logger.error("something wrong on reload item from index \(foundIndexPath) to index \(item.indexPath) isRemovedSection \(isRemovedSection) ")
                }
            } else { //if cache.count < beforeCount
                changeSections.append(.delete(foundIndexPath.section))
                changeItems.append(.move(foundIndexPath, item.indexPath, item.item!))
            }
        }
        return foundIndexPath != nil
    }
    
    private func delete(
        dtos: [DTO],
        in cache: Cache,
        changeItems: inout [ChangeItem],
        changeSections: inout [ChangeSection]
    ) {
        var group = Dictionary(uniqueKeysWithValues: dtos.map{($0.objectID, $0) })
        for (section, objects) in cache.cache.enumerated().reversed() {
            for (row, item) in objects.enumerated().reversed() {
                if group[item.objectID] != nil,
                   hasMapped(objectId: item.objectID, cache: cache) {
                    cache.cache[section].remove(at: row)
                    cache.mapDeletedItems[item.objectID] = cache.mapItems[item.objectID]
                    cache.mapItems[item.objectID] = nil
                    changeItems.append(.delete(.init(row: row, section: section)))
                    if cache.cache[section].isEmpty {
                        cache.cache.remove(at: section)
                        changeSections.append(.delete(section))
                    }
                    group[item.objectID] = nil
                } else if group.isEmpty {
                    return
                }
            }
        }
    }
    
    private func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter
            .addObserver(self,
                         selector: #selector(willSaveObjects(notification:)),
                         name: NSNotification.Name.NSManagedObjectContextWillSave,
                         object: nil)
        notificationCenter
            .addObserver(self,
                         selector: #selector(didSaveObjects(notification:)),
                         name: NSNotification.Name.NSManagedObjectContextDidSave,
                         object: nil)
        notificationCenter
            .addObserver(self,
                         selector: #selector(didChangeObjects(notification:)),
                         name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                         object: nil)
    }
    
    private func removeObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextWillSave, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    private func sorted(_ set: Set<NSManagedObject>) -> [DTO] {
        NSArray(array: set.compactMap { $0 as? DTO})
            .ns_filtered(using: fetchPredicate)
            .sortedArray(using: sortDescriptors)
            .compactMap { $0 as? DTO }
    }
    
    private func clearCache() {
        self.mainCaches.mainCache.mapItems.removeAll(keepingCapacity: true)
        self.mainCaches.mainCache.mapDeletedItems.removeAll()
        self.mainCaches.workingCache.mapItems.removeAll(keepingCapacity: true)
        self.mainCaches.workingCache.mapDeletedItems.removeAll()
        mainCaches.mainCache.cache.removeAll(keepingCapacity: true)
        mainCaches.workingCache.cache.removeAll(keepingCapacity: true)
        mainCaches.prevCache?.removeAll(keepingCapacity: true)
    }
    
    private func willChangeCache() {
        mainCaches.prevCache = mainCaches.mainCache.cache
    }
    
    private func queue( _ block: @escaping () -> Void) {
        if Thread.isMainThread {
            if eventQueue.label == "com.apple.main-thread" {
                block()
                return
            }
        }
        eventQueue.async {
            block()
        }
    }
    
    private func perform( _ block: @escaping () -> Void) {
        if Thread.isMainThread {
            if context === viewContext {
                context.performAndWait {
                    self.queue {}
                    block()
                }
                return
            }
        }
        context.perform {
            self.queue {}
            block()
        }
    }
    
    private func performAndWait<T>( _ block: @escaping () -> T) -> T {
        var result: T!
        context.performAndWait {
            self.queue {}
            result = block()
        }
        return result
    }
    
    private func didUpdate(
        insertCache: Cache,
        paths: ChangeItemPaths,
        done: (() -> Void)?
    ) {
        if insertCache.cache.count == 3 {
            fatalError()
        }
        guard isObserverStarted else { return }
        self.mainCaches.workingCache = insertCache.copy()
        debugPrint(
            "[CACHE EVENT] before update",
            insertCache.cache.first?.count, "in",paths.inserts.count, "del", paths.deletes.count)
        let userInfo = self.onWillChange?(self.mainCaches.workingCache.cache, paths)
        self.queue {[weak self] in
            guard let self else { return }
            guard self.isObserverStarted || self.isObserverRestarting
            else {
                self.performAndWait { self.clearCache() }
                return
            }
            debugPrint(
                "[CACHE EVENT] after update",
                insertCache.cache.first?.count,
                "in",
                paths.inserts.count,
                "del",
                paths.deletes.count,
                "total",
                insertCache.cache.count
            )
            self.mainCaches.mainCache = insertCache.copy()
            self.onDidChange?(false, paths, userInfo)
            done?()
        }
    }
    
    private func hasMapped(objectId: NSManagedObjectID, cache: Caches) -> Bool {
        cache.mainCache.mapItems[objectId] != nil || cache.workingCache.mapItems[objectId] != nil
    }
    
    private func hasMapped(objectId: NSManagedObjectID, cache: Cache) -> Bool {
        cache.mapItems[objectId] != nil
    }
    
    private func mappedItem(objectId: NSManagedObjectID) -> Item? {
        mappedItem(objectId: objectId, cache: mainCaches)
    }
    
    private func mappedItem(objectId: NSManagedObjectID, cache: Caches) -> Item? {
        cache.mainCache.mapItems[objectId] ?? cache.workingCache.mapItems[objectId]
    }
}

public extension LazyDatabaseObserver {
    
    final public class FetchBuilder {
        
        final public class Request {
            public lazy var fetchRequest: NSFetchRequest<DTO>? = DTO.fetchRequest() as? NSFetchRequest<DTO>
            public var reversed: Bool = false
        }
        
        private weak var ldo: LazyDatabaseObserver?
        private var requests = [Request]()
        fileprivate init(ldo: LazyDatabaseObserver) {
            self.ldo = ldo
        }
        
        public func makeRequest() -> Request {
            requests.append(Request())
            return requests.last!
        }
        
        public func fetchAndUpdate(done: ((ChangeItemPaths) -> Void)? = nil) {
            guard let ldo else {
                done?(.init(changeItems: []))
                return
            }
            
            guard ldo.isObserverStarted else {
                done?(.init(changeItems: []))
                return
            }
            ldo.willChangeCache()
            
            ldo.fetchAndUpdate(requests: requests, done: done)
        }
        
    }
    
    enum ChangeItem: Comparable {
        
        public static func < (lhs: ChangeItem, rhs: ChangeItem) -> Bool {
            lhs.indexPath < rhs.indexPath
        }
        
        public static func == (lhs: ChangeItem, rhs: ChangeItem) -> Bool {
            lhs.indexPath == rhs.indexPath
        }
        
        case insert(IndexPath, Item)
        case delete(IndexPath)
        case move(IndexPath, IndexPath, Item)
        case update(IndexPath, Item)
        
        public var indexPath: IndexPath {
            switch self {
            case .insert(let indexPath, _),
                    .delete(let indexPath),
                    .move(let indexPath, _, _),
                    .update(let indexPath, _):
                return indexPath
            }
        }
        
        public var item: Item? {
            switch self {
            case .insert(_, let item),
                    .move(_, _, let item),
                    .update(_, let item):
                return item
            default:
                return nil
            }
        }
    }
    
    enum ChangeSection {
        case insert(Int)
        case delete(Int)
        
        var section: Int {
            switch self {
            case .insert( let section ), .delete( let section ):
                return section
            }
        }
    }
    
    struct ChangeItemPaths {
        
        public var inserts = [IndexPath]()
        public var updates = [IndexPath]()
        public var deletes = [IndexPath]()
        public var moves = [(from: IndexPath, to: IndexPath)]()
        
        public var sectionInserts = IndexSet()
        public var sectionDeletes = IndexSet()
        
        public let changeItems: [ChangeItem]
        public let changeSections: [ChangeSection]
        
        public var isEmpty: Bool {
            inserts.isEmpty &&
            updates.isEmpty &&
            deletes.isEmpty &&
            moves.isEmpty &&
            sectionInserts.isEmpty &&
            sectionDeletes.isEmpty
        }
        
        public var numberOfChangedItems: Int {
            changeItems.count + changeSections.count
        }
        
        public init(changeItems: [ChangeItem],
                    changeSections: [ChangeSection] = []) {
            self.changeItems = changeItems
            self.changeSections = changeSections
            var toDelete = [IndexPath: Bool]()
            changeItems.forEach { item in
                switch item {
                case let .insert(indexPath, _):
                    inserts.append(indexPath)
                case let .update(indexPath, _):
                    updates.append(indexPath)
                case let .delete(indexPath):
                    deletes.append(indexPath)
                    toDelete[indexPath] = true
                case let .move(indexPath, newIndexPath, _):
                    moves.append((indexPath, newIndexPath))
                    toDelete[indexPath] = true
                }
            }
           
            let updatesCount = updates.count
            updates = updates.filter({ indexPath in
                toDelete[indexPath] == nil
            })
            
            changeSections.forEach { section in
                switch section {
                case let .insert(s):
                    var ns = s
                    while sectionInserts.contains(ns) {
                        ns += 1
                    }
                    sectionInserts.insert(ns)
                case let .delete(s):
                    var ns = s
                    while sectionDeletes.contains(ns) {
                        ns += 1
                    }
                    sectionDeletes.insert(ns)
                }
            }
        }
    }
    
}

private extension NSArray {
    func ns_filtered(using predicate: NSPredicate) -> NSArray {
        filtered(using: predicate) as NSArray
    }
}

internal extension LazyDatabaseObserver.ChangeItemPaths {
    
    var description: String {
        "[ChangeItemPaths]: INSERTS: \(inserts), UPDATES: \(updates), DELETES: \(deletes), MOVES: \(moves), SEC_INS \(sectionInserts), SEC_DEL \(sectionDeletes)"
    }
}
