//
//  PersistenceManager.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
import CoreData

protocol PersistenceManagable: AnyObject {
    var modelName: String { get }
    var persistentContainer: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }
    @discardableResult func saveContext() -> Bool
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]?
}

class PersistenceManager: PersistenceManagable {
    private(set) var modelName = "BoostPocket"

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                dump(error)
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support

    // TODO: saveContext 자체 테스트할 것
    @discardableResult
    func saveContext() -> Bool {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                let nserror = error as NSError
                print(nserror.localizedDescription)
                return false
            }
        }
        
        return false // 주의
    }
    
    // MARK: - Core Data Fetching support
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]? {
        do {
            let fetchedResult = try self.context.fetch(request)
            return fetchedResult
        } catch {
            return nil
        }
    }
}
