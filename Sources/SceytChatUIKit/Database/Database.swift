//
//  Database.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 26.10.23.
//  Copyright © 2023 Sceyt LLC. All rights reserved.
//

import Foundation
import CoreData

public protocol Database {
    
    func write(resultQueue: DispatchQueue,
               _ perform: @escaping (NSManagedObjectContext) throws -> Void,
               completion: ((Error?) -> Void)?)
    func performWriteTask(resultQueue: DispatchQueue,
                          _ perform: @escaping (NSManagedObjectContext) throws -> Void,
                          completion: ((Error?) -> Void)?)
    func syncWrite(_ perform: @escaping (NSManagedObjectContext) throws -> Void) throws
    func read<Fetch>(resultQueue: DispatchQueue,
                     _ perform: @escaping (NSManagedObjectContext) throws -> Fetch,
                     completion: ((Result<Fetch, Error>) -> Void)?)
    func read<Fetch>(_ perform: @escaping (NSManagedObjectContext) throws -> Fetch) -> Result<Fetch, Error>
    func performBgTask<Fetch>(resultQueue: DispatchQueue,
                     _ perform: @escaping (NSManagedObjectContext) throws -> Fetch,
                     completion: ((Result<Fetch, Error>) -> Void)?)
    
    var viewContext: NSManagedObjectContext { get }
    var backgroundPerformContext: NSManagedObjectContext { get }
    var backgroundReadOnlyContext: NSManagedObjectContext { get }
    var backgroundReadOnlyObservableContext: NSManagedObjectContext { get }
    
    func recreate(completion: @escaping ((Error?) -> Void))
    func deleteAll(completion: (() -> Void)?)
}

public extension Database {
    
    func write(_ perform: @escaping (NSManagedObjectContext) throws -> Void,
               completion: ((Error?) -> Void)?) {
        write(resultQueue: .main, perform, completion: completion)
    }
    
    func read<Fetch>(_ perform: @escaping (NSManagedObjectContext) throws -> Fetch,
                     completion: ((Result<Fetch, Error>) -> Void)?) {
        read(resultQueue: .main, perform, completion: completion)
    }
    
    func write(_ perform: @escaping (NSManagedObjectContext) throws -> Void) {
        write(perform, completion: { _ in })
    }
    
    func performWriteTask(_ perform: @escaping (NSManagedObjectContext) throws -> Void, completion: ((Error?) -> Void)?) {
        performWriteTask(resultQueue: .main, perform, completion: completion)
    }
    
    func performWriteTask(_ perform: @escaping (NSManagedObjectContext) throws -> Void) {
        performWriteTask(resultQueue: .main, perform, completion: nil)
    }
    
    func performBgTask<Fetch>(_ perform: @escaping (NSManagedObjectContext) throws -> Fetch,
                              completion: ((Result<Fetch, Error>) -> Void)?) {
        performBgTask(resultQueue: .main, perform, completion: completion)
    }
    
    func performBgTask<Fetch>(_ perform: @escaping (NSManagedObjectContext) throws -> Fetch) {
        performBgTask(resultQueue: .main, perform, completion: nil)
    }
    
    func refreshAllObjects(
        resetStalenessInterval: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        logger.debug("[DATABASE REFRESH] Starting refreshAllObjects with resetStalenessInterval=\(resetStalenessInterval)")
        
        if resetStalenessInterval {
            self.backgroundPerformContext.stalenessInterval = 0
            logger.debug("[DATABASE REFRESH] Set backgroundPerformContext stalenessInterval to 0")
        }
        logger.debug("[DATABASE REFRESH] Refreshing backgroundPerformContext")
        self.backgroundPerformContext.refreshAllObjects()
        if resetStalenessInterval {
            self.backgroundPerformContext.stalenessInterval = -1
            logger.debug("[DATABASE REFRESH] Reset backgroundPerformContext stalenessInterval to -1")
        }
        
        if resetStalenessInterval {
            self.backgroundReadOnlyObservableContext.stalenessInterval = 0
            logger.debug("[DATABASE REFRESH] Set backgroundReadOnlyObservableContext stalenessInterval to 0")
        }
        logger.debug("[DATABASE REFRESH] Refreshing backgroundReadOnlyObservableContext")
        self.backgroundReadOnlyObservableContext.refreshAllObjects()
        if resetStalenessInterval {
            self.backgroundReadOnlyObservableContext.stalenessInterval = -1
            logger.debug("[DATABASE REFRESH] Reset backgroundReadOnlyObservableContext stalenessInterval to -1")
        }
        
        if resetStalenessInterval {
            self.viewContext.stalenessInterval = 0
            logger.debug("[DATABASE REFRESH] Set viewContext stalenessInterval to 0")
        }
        logger.debug("[DATABASE REFRESH] Refreshing viewContext")
        self.viewContext.refreshAllObjects()
        if resetStalenessInterval {
            self.viewContext.stalenessInterval = -1
            logger.debug("[DATABASE REFRESH] Reset viewContext stalenessInterval to -1")
        }
        logger.debug("[DATABASE REFRESH] refreshAllObjects completed")
        completion?()
    }
    
    func deleteAll() {
        deleteAll(completion: nil)
    }
}

public final class PersistentContainer: NSPersistentContainer, Database {
    
    private lazy var observersQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public required init(modelName: String = "SceytChatModel", bundle: Bundle? = nil, storeType: StoreType) {
        logger.debug("[DATABASE INIT] Starting database initialization with model: \(modelName)")
        let modelBundle = bundle ?? Bundle.kit(for: PersistentContainer.self)
        guard let modelUrl = modelBundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("file \(modelName).momd font found")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("cant't create model for \(modelUrl)")
        }
        super.init(name: modelName, managedObjectModel: model)
        setPersistentStoreDescription(type: storeType)
        logger.debug("[DATABASE INIT] Loading persistent stores...")
        loadPersistentStores {[weak self] _, error in
            if let error = error {
                logger.errorIfNotNil(error, "[DATABASE INIT] Failed to load persistent stores")
                self?.tryRecreatePersistentStore(completion: { error in
                    if let error = error {
                        logger.errorIfNotNil(error, "[DATABASE INIT] Failed to recreate persistent store")
                    } else {
                        logger.debug("[DATABASE INIT] Successfully recreated persistent store")
                    }
                })
            } else {
                logger.debug("[DATABASE INIT] Successfully loaded persistent stores")
            }
        }
        logger.debug("[DATABASE INIT] Configuring viewContext with mergePolicy and automaticallyMergesChangesFromParent")
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.automaticallyMergesChangesFromParent = true
        addObservers()
        logger.debug("[DATABASE INIT] Database initialization completed")
    }
    
    private func tryRecreatePersistentStore(completion: @escaping ((Error?) -> Void)) {
        
        guard let storeDescription = persistentStoreDescriptions.first else {
            completion(NSError(reason: "Not found PersistentStoreDescriptions"))
            return
        }
        
        do {
            try persistentStoreCoordinator.persistentStores.forEach {
                try persistentStoreCoordinator.remove($0)
            }
            if let storeURL = storeDescription.url, !storeURL.absoluteString.hasSuffix("/dev/null") {
                try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: storeDescription.type, options: nil)
            }
        } catch {
            completion(error)
            return
        }
        
        loadPersistentStores {
            completion($1)
        }
    }
    
    private func setPersistentStoreDescription(type: StoreType) {
        let description = NSPersistentStoreDescription()
        
        switch type {
        case .sqLite(let fileUrl):
            description.url = fileUrl
        case .binary(let fileUrl):
            description.url = fileUrl
        case .inMemory:
            // https://useyourloaf.com/blog/core-data-in-memory-store/
            if #available(iOS 13, *) {
                description.url = URL(fileURLWithPath: "/dev/null")
            } else {
                description.type = NSInMemoryStoreType
            }
        }
        logger.debug("Database file url \(description.url)")
        persistentStoreDescriptions = [description]
    }
    
    public lazy var backgroundPerformContext: NSManagedObjectContext = {
        logger.debug("[DATABASE CONTEXT] Creating backgroundPerformContext")
        let context = newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        logger.debug("[DATABASE CONTEXT] backgroundPerformContext created with automaticallyMergesChangesFromParent=true")
        return context
    }()
   
    public lazy var backgroundReadOnlyContext: NSManagedObjectContext = {
        logger.debug("[DATABASE CONTEXT] Creating backgroundReadOnlyContext")
        let context = newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        logger.debug("[DATABASE CONTEXT] backgroundReadOnlyContext created with automaticallyMergesChangesFromParent=true")
        return context
    }()
    
    public lazy var backgroundReadOnlyObservableContext: NSManagedObjectContext = {
        logger.debug("[DATABASE CONTEXT] Creating backgroundReadOnlyObservableContext")
        let context = newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        context.retainsRegisteredObjects = true
        logger.debug("[DATABASE CONTEXT] backgroundReadOnlyObservableContext created with automaticallyMergesChangesFromParent=true and retainsRegisteredObjects=true")
        return context
    }()
    
    public func createBackgroundContext() -> NSManagedObjectContext {
        logger.debug("[DATABASE CONTEXT] Creating new background context")
        let context = newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        logger.debug("[DATABASE CONTEXT] New background context created with automaticallyMergesChangesFromParent=true")
        return context
    }
    
    public final func write(resultQueue: DispatchQueue,
                            _ perform: @escaping (NSManagedObjectContext) throws -> Void,
                            completion: ((Error?) -> Void)? = nil) {
        logger.debug("[DATABASE WRITE] Scheduling write operation on backgroundPerformContext")
        backgroundPerformContext.perform {[weak self] in
            guard let self = self else {
                logger.debug("[DATABASE WRITE] Self deallocated before write could execute")
                return
            }
            logger.debug("[DATABASE WRITE] Starting write operation on backgroundPerformContext")
            do {
                defer { resultQueue.async { completion?(nil) } }
                try perform(self.backgroundPerformContext)
                logger.debug("[DATABASE WRITE] Write operation completed, checking for updated objects")
                for object in self.backgroundPerformContext.updatedObjects {
                    if object.changedValues().isEmpty {
                        self.backgroundPerformContext.refresh(object, mergeChanges: false)
                    }
                }
                
                // FIXME: - Database Logs

                if self.backgroundPerformContext.hasChanges {
                    self.logUncommittedChanges(context: self.backgroundPerformContext)
                    logger.info("[DATABASE WRITE] Will save on backgroundPerformContext - hasChanges=true")
                    try self.backgroundPerformContext.save()
                    logger.info("[DATABASE WRITE] Successfully saved on backgroundPerformContext")
                } else {
                    logger.debug("[DATABASE WRITE] No changes to save on backgroundPerformContext")
                }
            } catch {
                logger.errorIfNotNil(error, "[DATABASE WRITE] Failed to save on backgroundPerformContext")
                resultQueue.async { completion?(error) }
            }
        }
    }
    
    func logUncommittedChanges(context: NSManagedObjectContext) {
        let insertedObjects = context.insertedObjects
        let updatedObjects = context.updatedObjects
        let deletedObjects = context.deletedObjects
        let registeredObjects = context.registeredObjects
        
        if !insertedObjects.isEmpty {
            logger.info("[DATABASE] Inserted Objects: \(insertedObjects.count)")
        }
        
        if !updatedObjects.isEmpty {
            logger.info("[DATABASE] Updated Objects: \(updatedObjects.count)")
        }
        
        if !deletedObjects.isEmpty {
            logger.info("[DATABASE] Deleted Objects: \(deletedObjects.count)")
        }
        
        if !registeredObjects.isEmpty {
            logger.info("[DATABASE] Registered Objects: \(registeredObjects.count)")
        }
    }
    
    public final func performWriteTask(resultQueue: DispatchQueue,
                                              _ perform: @escaping (NSManagedObjectContext) throws -> Void,
                                              completion: ((Error?) -> Void)? = nil) {
        logger.debug("[DATABASE WRITE TASK] Creating new background context for write task")
        let context = createBackgroundContext()
        logger.debug("[DATABASE WRITE TASK] Scheduling write task on new background context")
        context.perform {[weak self] in
            guard let self = self else {
                logger.debug("[DATABASE WRITE TASK] Self deallocated before write task could execute")
                return
            }
            logger.debug("[DATABASE WRITE TASK] Starting write task on new background context")
            do {
                defer { resultQueue.async { completion?(nil) } }
                try perform(context)
                logger.debug("[DATABASE WRITE TASK] Write task completed, checking for updated objects")
                for object in context.updatedObjects {
                    if object.changedValues().isEmpty {
                        context.refresh(object, mergeChanges: false)
                    }
                }
                if context.hasChanges {
                    logger.info("[DATABASE WRITE TASK] Will save on new background context - hasChanges=true")
                    try context.save()
                    logger.info("[DATABASE WRITE TASK] Successfully saved on new background context")
                } else {
                    logger.debug("[DATABASE WRITE TASK] No changes to save on new background context")
                }
            } catch {
                logger.errorIfNotNil(error, "[DATABASE WRITE TASK] Failed to save on new background context")
                resultQueue.async { completion?(error) }
            }
        }
    }
    
    public final func syncWrite(_ perform: @escaping (NSManagedObjectContext) throws -> Void) throws {
        logger.debug("[DATABASE SYNC WRITE] Starting synchronous write operation")
        var _error: Error?
        backgroundPerformContext.performAndWait {
            logger.debug("[DATABASE SYNC WRITE] Executing synchronous write on backgroundPerformContext")
            do {
                try perform(self.backgroundPerformContext)
                logger.debug("[DATABASE SYNC WRITE] Sync write completed, checking for updated objects")
                self.backgroundPerformContext.updatedObjects.forEach {
                    guard $0.changedValues().isEmpty else {
                        return
                    }
                    self.backgroundPerformContext.refresh($0, mergeChanges: false)
                }
                guard self.backgroundPerformContext.hasChanges else {
                    logger.debug("[DATABASE SYNC WRITE] No changes to save")
                    return
                }
                logger.info("[DATABASE SYNC WRITE] Will save on backgroundPerformContext - hasChanges=true")
                try self.backgroundPerformContext.save()
                logger.info("[DATABASE SYNC WRITE] Successfully saved on backgroundPerformContext")
                
            } catch {
                logger.errorIfNotNil(error, "[DATABASE SYNC WRITE] Failed to save on backgroundPerformContext")
                _error = error
            }
        }
        if let _error {
            throw _error
        }
    }
    
    public final func read<Fetch>(resultQueue: DispatchQueue,
                                  _ perform: @escaping (NSManagedObjectContext) throws -> Fetch,
                                  completion: ((Result<Fetch, Error>) -> Void)?) {
        logger.debug("[DATABASE READ] Scheduling read operation on backgroundReadOnlyContext")
        let context = backgroundReadOnlyContext
        context.perform {[weak self] in
            guard self != nil else {
                logger.debug("[DATABASE READ] Self deallocated before read could execute")
                return
            }
            logger.debug("[DATABASE READ] Starting read operation on backgroundReadOnlyContext")
            do {
                let fetch = try perform(context)
                logger.debug("[DATABASE READ] Read operation completed successfully")
                resultQueue.async {
                    completion?(.success(fetch))
                }
            } catch {
                logger.errorIfNotNil(error, "[DATABASE READ] Read operation failed")
                resultQueue.async {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    public final func read<Fetch>(_ perform: @escaping (NSManagedObjectContext) throws -> Fetch) -> Result<Fetch, Error> {
        let isMainThread = Thread.isMainThread
        logger.debug("[DATABASE SYNC READ] Starting synchronous read on \(isMainThread ? "viewContext" : "backgroundReadOnlyContext")")
        var result: Result<Fetch, Error>!
        let context = isMainThread ? viewContext : backgroundReadOnlyContext
        context.performAndWait {
            logger.debug("[DATABASE SYNC READ] Executing synchronous read")
            do {
                let fetch = try perform(context)
                logger.debug("[DATABASE SYNC READ] Synchronous read completed successfully")
                result = .success(fetch)
            } catch {
                logger.errorIfNotNil(error, "[DATABASE SYNC READ] Synchronous read failed")
                result = .failure(error)
            }
        }
        return result
    }
    
    public final func performBgTask<Fetch>(resultQueue: DispatchQueue,
                                           _ perform: @escaping (NSManagedObjectContext) throws -> Fetch,
                                           completion: ((Result<Fetch, Error>) -> Void)? = nil) {
        logger.debug("[DATABASE BG TASK] Creating new background context for bg task")
        let context = createBackgroundContext()
        logger.debug("[DATABASE BG TASK] Scheduling bg task on new background context")
        context.perform {
            guard self != nil else {
                logger.debug("[DATABASE BG TASK] Self deallocated before bg task could execute")
                return
            }
            logger.debug("[DATABASE BG TASK] Starting bg task on new background context")
            do {
                let fetch = try perform(context)
                logger.debug("[DATABASE BG TASK] Bg task completed successfully")
                resultQueue.async {
                    completion?(.success(fetch))
                }
            } catch {
                logger.errorIfNotNil(error, "[DATABASE BG TASK] Bg task failed")
                resultQueue.async {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    public func recreate(completion: @escaping ((Error?) -> Void)) {
        backgroundPerformContext.perform {
            self.tryRecreatePersistentStore(completion: completion)
        }
    }
    
    public func deleteAll(completion: (() -> Void)? = nil) {
        logger.debug("[DATABASE DELETE] Starting deleteAll operation")
        backgroundPerformContext.perform {
            logger.debug("[DATABASE DELETE] Executing batch delete for all entities")
            for key in self.managedObjectModel.entitiesByName.keys {
                logger.debug("[DATABASE DELETE] Batch deleting entity: \(key)")
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: key)
                try? self.backgroundPerformContext.batchDelete(fetchRequest: request)
            }
            logger.debug("[DATABASE DELETE] deleteAll operation completed")
            completion?()
        }
    }
    
    deinit {
        logger.debug("[DATABASE DEINIT] PersistentContainer is being deallocated")
        NotificationCenter.default
            .removeObserver(
                self,
                name: .NSManagedObjectContextDidSave,
                object: backgroundPerformContext)
        logger.debug("[DATABASE DEINIT] Removed observers")
    }
}

public extension PersistentContainer {
    
    enum StoreType {
        case sqLite(databaseFileUrl: URL)
        case binary(fileUrl: URL)
        case inMemory
        
        public var rawValue: String {
            switch self {
            case .sqLite:
                return NSSQLiteStoreType
            case .binary:
                return NSBinaryStoreType
            case .inMemory:
                return NSInMemoryStoreType
            }
        }
    }
}

private extension PersistentContainer {
    
    func addObservers() {
        logger.debug("[DATABASE OBSERVER] Adding didSave observer for backgroundPerformContext")
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didSave(notification: )), name: .NSManagedObjectContextDidSave, object: backgroundPerformContext)
        logger.debug("[DATABASE OBSERVER] didSave observer added successfully")
    }
    
    func removeObservers() {
        logger.debug("[DATABASE OBSERVER] Removing didSave observer")
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
        logger.debug("[DATABASE OBSERVER] didSave observer removed")
    }
    
    @objc
    func didSave(notification: Notification) {
        logger.debug("[DATABASE MERGE] didSave notification received")
        if (notification.object as? NSManagedObjectContext) === backgroundPerformContext {
            logger.info("[DATABASE MERGE] Will merge changes from backgroundPerformContext to backgroundReadOnlyObservableContext")
            
            // Log the changes being merged
            if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
                logger.info("[DATABASE MERGE] Inserted objects count: \(insertedObjects.count)")
            }
            if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                logger.info("[DATABASE MERGE] Updated objects count: \(updatedObjects.count)")
            }
            if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
                logger.info("[DATABASE MERGE] Deleted objects count: \(deletedObjects.count)")
            }
            
            backgroundReadOnlyObservableContext.perform {
                logger.debug("[DATABASE MERGE] Starting mergeChanges on backgroundReadOnlyObservableContext")
                do {
                    logger.debug("[DATABASE MERGE] Calling mergeChanges(fromContextDidSave:)")
                    self.backgroundReadOnlyObservableContext.mergeChanges(fromContextDidSave: notification)
                    logger.info("[DATABASE MERGE] Successfully merged changes to backgroundReadOnlyObservableContext")
                } catch {
                    logger.errorIfNotNil(error, "[DATABASE MERGE] Error during merge to backgroundReadOnlyObservableContext")
                }
            }
        } else {
            logger.debug("[DATABASE MERGE] didSave notification ignored - not from backgroundPerformContext")
        }
    }
}

fileprivate extension NSError {
    
    convenience init(reason: String) {
        self.init(domain: "com.sceytchat.uikit.database", code: -1, userInfo: [NSLocalizedDescriptionKey: reason])
    }
}


public extension NSManagedObjectContext {
    
    func mergeChangesWithViewContext(fromRemoteContextSave: [AnyHashable: Any]) {
        logger.debug("[DATABASE MERGE EXTENSION] Starting mergeChangesWithViewContext")
        
        // Log the changes being merged
        if let insertedObjects = fromRemoteContextSave[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            logger.info("[DATABASE MERGE EXTENSION] Inserted objects count: \(insertedObjects.count)")
        }
        if let updatedObjects = fromRemoteContextSave[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            logger.info("[DATABASE MERGE EXTENSION] Updated objects count: \(updatedObjects.count)")
        }
        if let deletedObjects = fromRemoteContextSave[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            logger.info("[DATABASE MERGE EXTENSION] Deleted objects count: \(deletedObjects.count)")
        }
        
        logger.debug("[DATABASE MERGE EXTENSION] Calling NSManagedObjectContext.mergeChanges")
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: fromRemoteContextSave,
            into: [self, SceytChatUIKit.shared.database.viewContext]
        )
        logger.info("[DATABASE MERGE EXTENSION] Successfully merged changes with viewContext")
    }
}
