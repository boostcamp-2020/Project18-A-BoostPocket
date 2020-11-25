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
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]
    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]?
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int?
    @discardableResult func createObject(newObjectInfo: InformationProtocol) -> DataModelProtocol?
    @discardableResult func saveContext() -> Bool
    @discardableResult func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> Bool?
    // @discardableResult func delete(object: NSManagedObject) -> Bool
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
    
    // MARK: - Core Data Creating support
    
    //TODO: - generic 쓰는 방식과 더 나은 코드 고민해보기
    @discardableResult
    func createObject(newObjectInfo: InformationProtocol) -> DataModelProtocol? {
        guard let entity = NSEntityDescription.entity(forEntityName: "Country", in: self.context) else { return nil }
                
        var createdObject: DataModelProtocol?
        
        switch newObjectInfo.informationType {
        case .CountryInfo:
            guard let newObjectInfo = newObjectInfo as? CountryInfo else { return nil }
            let newCountry = Country(entity: entity, insertInto: context)
            setupCountryInfo(newCountry: newCountry, countryInfo: newObjectInfo)
            createdObject = newCountry
        case .TravelInfo:
            return nil
        case .HistoryInfo:
            return nil
        }
        
        do {
            try self.context.save()
            return createdObject
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func setupCountryInfo(newCountry: Country, countryInfo: CountryInfo) {
        newCountry.name = countryInfo.name
        newCountry.lastUpdated = countryInfo.lastUpdated
        newCountry.flagImage = countryInfo.flagImage
        newCountry.exchangeRate = countryInfo.exchangeRate
        newCountry.currencyCode = countryInfo.currencyCode
    }
    
    // MARK: - Core Data Fetching support
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        if T.self == Country.self {
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSort]
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
    
    // TODO: - 리턴값 optional에서 Bool로 바꾸고, provider 코드에서도 변경사항 적용하기
    // TODO: - 테스트코드 작성
    @discardableResult
    func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> Bool? {
        let request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.context.execute(delete)
            return true
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // TODO: - 특정 Object 삭제 코드
//    @discardableResult
//    func delete(object: NSManagedObject) -> Bool {
//        self.context.delete(object)
//        do {
//            try context.save()
//            return true
//        } catch {
//            return false
//        }
//    }
  
    // MARK: - Core Data Counting support
    
    // TODO: - 테스트코드 작성
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
