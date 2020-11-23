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
    func saveContext()
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]?
}

class PersistenceManager: PersistenceManagable {
    private(set) var modelName = "BoostPocket"

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores() { (storeDescription, error) in
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

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print(nserror.localizedDescription)
            }
        }
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
