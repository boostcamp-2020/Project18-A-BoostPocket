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
    func fetchAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]
    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]?
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int?
    func createObject<T>(newObjectInfo: T) -> DataModelProtocol?
    func delete<T>(deletingObject: T) -> Bool
    @discardableResult func saveContext() -> Bool
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
    
    @discardableResult
    func saveContext() -> Bool {
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
    
    // MARK: - Core Data Creating support
    
    func createObject<T>(newObjectInfo: T) -> DataModelProtocol? {
        var createdObject: DataModelProtocol?
        
        if let newCountryInfo = newObjectInfo as? CountryInfo {
            createdObject = setupCountryInfo(countryInfo: newCountryInfo)
        } else if let newTravelInfo = newObjectInfo as? TravelInfo {
            createdObject = setupTravelInfo(travelInfo: newTravelInfo)
        }
        
        do {
            try self.context.save()
            return createdObject
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func setupCountryInfo(countryInfo: CountryInfo) -> Country? {
        guard let entity = NSEntityDescription.entity(forEntityName: Country.entityName, in: self.context) else { return nil }
        let newCountry = Country(entity: entity, insertInto: context)
        
        newCountry.name = countryInfo.name
        newCountry.lastUpdated = countryInfo.lastUpdated
        newCountry.flagImage = countryInfo.flagImage
        newCountry.exchangeRate = countryInfo.exchangeRate
        newCountry.currencyCode = countryInfo.currencyCode
        
        return newCountry
    }
    
    private func setupTravelInfo(travelInfo: TravelInfo) -> Travel? {
        guard let entity = NSEntityDescription.entity(forEntityName: Travel.entityName, in: self.context) else { return nil }
        let newTravel = Travel(entity: entity, insertInto: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", travelInfo.countryName)
        
        guard let countries = fetch(fetchRequest) as? [Country],
            let fetchedCountry = countries.first
            else { return nil }
        
        newTravel.title = fetchedCountry.name
        newTravel.exchangeRate = fetchedCountry.exchangeRate
        newTravel.country = fetchedCountry
        // TODO : endDate 나중에 없애기
        newTravel.startDate = Date()
        newTravel.endDate = Date()
        newTravel.id = UUID()
        newTravel.coverImage = Data().getCoverImage()
        
        return newTravel
    }
    
    // MARK: - Core Data Fetching support
    
    func fetchAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        if T.self == Country.self {
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSort]
        } else if T.self == Travel.self {
            let startDateSort = NSSortDescriptor(key: "startDate", ascending: true)
            request.sortDescriptors = [startDateSort]
        }
        
        do {
            let fetchedResult = try self.context.fetch(request)
            return fetchedResult
        } catch {
            return []
        }
    }
    
    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]? {
        do {
            let fetchResult = try self.context.fetch(request)
            return fetchResult
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Core Data Deleting support

    func delete<T>(deletingObject: T) -> Bool {
        
        if let travelObject = deletingObject as? Travel {
            self.context.delete(travelObject)
        } else if let countryObject = deletingObject as? Country {
            self.context.delete(countryObject)
        }

        do {
            try context.save()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    // MARK: - Core Data Counting support
    
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int? {
        do {
            let count = try self.context.count(for: request)
            return count
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
