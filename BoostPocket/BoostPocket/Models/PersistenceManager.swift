//
//  PersistenceManager.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
import CoreData
import NetworkManager
import FlagKit

protocol PersistenceManagable: AnyObject {
    var modelName: String { get }
    var persistentContainer: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }
    
    func createCountriesWithAPIRequest(completion: @escaping (Bool) -> Void)
    func filterCountries(_ identifiers: [String], rates: [String: Double]) -> [String: String]
    func createObject<T>(newObjectInfo: T, completion: @escaping (DataModelProtocol?) -> Void)
    func fetchAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]
    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]?
    func isExchangeRateOutdated(lastUpdated: Date) -> Bool
    func updateObject<T>(updatedObjectInfo: T) -> DataModelProtocol?
    func delete<T>(deletingObject: T) -> Bool
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int?
    func setupTravelInfo(travelInfo: TravelInfo, completion: @escaping (Travel?) -> Void)
    func saveContext()
}

class PersistenceManager: PersistenceManagable {
    private weak var dataLoader: DataLoader?
    private(set) var modelName = "BoostPocket"
    private let exchangeRateAPIurl = "https://api.exchangeratesapi.io/latest?base=KRW"
    
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
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
    func createCountriesWithAPIRequest(completion: @escaping (Bool) -> Void) {
        dataLoader?.requestExchangeRate(url: exchangeRateAPIurl) { [weak self] (result) in
            guard let self = self, let numberOfCountries = self.count(request: Country.fetchRequest()) else {
                completion(false)
                return
            }
            
            switch result {
            case .success(let data):
                if numberOfCountries <= 0 {
                    print("setup countries")
                    self.setupCountries(with: data)
                    completion(true)
                }
            case .failure(let error):
                print("Network Error")
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    // TODO: - 테스트코드 작성하기
    private func setupCountries(with data: ExchangeRate) {
        let koreaLocale = NSLocale(localeIdentifier: "ko_KR")
        let identifiers = NSLocale.availableLocaleIdentifiers
        let countryDictionary = filterCountries(identifiers, rates: data.rates)
        
        countryDictionary.forEach { (countryCode, identifier) in
            let locale = NSLocale(localeIdentifier: identifier)
            if let currencyCode = locale.currencyCode,
                let countryName = koreaLocale.localizedString(forCountryCode: countryCode),
                let exchangeRate = data.rates[currencyCode],
                let flagImage = Flag(countryCode: countryCode)?.image(style: .roundedRect).pngData() {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                let date: Date = dateFormatter.date(from: data.date) ?? Date()
                
                createObject(newObjectInfo: CountryInfo(name: countryName, lastUpdated: date, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)) { _ in }
            }
        }
    }
    
    func filterCountries(_ identifiers: [String], rates: [String: Double]) -> [String: String] {
        var filteredIdentifiers: [String: String] = [:]
        
        identifiers.forEach { identifier in
            let locale = NSLocale(localeIdentifier: identifier)
            if let currencyCode = locale.currencyCode,
                let countryCode = locale.countryCode,
                let _ = rates[currencyCode],
                let _ = Flag(countryCode: countryCode)?.originalImage.pngData() {
                filteredIdentifiers[countryCode] = identifier
            }
        }
        
        return filteredIdentifiers
    }
}

// MARK: - Core Data Saving support

extension PersistenceManager {
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("saveContext Error")
                print(nserror.localizedDescription)
            }
        }
    }
}

// MARK: - Core Data Creating support

extension PersistenceManager {
    func createObject<T>(newObjectInfo: T, completion: @escaping (DataModelProtocol?) -> Void) {
        var createdObject: DataModelProtocol?
        
        if let newCountryInfo = newObjectInfo as? CountryInfo {
            createdObject = setupCountryInfo(countryInfo: newCountryInfo)
            saveContext()
            completion(createdObject)
        } else if let newTravelInfo = newObjectInfo as? TravelInfo {
            setupTravelInfo(travelInfo: newTravelInfo) { [weak self] (newTravel) in
                createdObject = newTravel
                self?.saveContext()
                completion(createdObject)
            }
        } else if let newHistoryInfo = newObjectInfo as? HistoryInfo {
            createdObject = setupHistoryInfo(historyInfo: newHistoryInfo)
            saveContext()
            completion(createdObject)
        }
    }
    
    private func setupHistoryInfo(historyInfo: HistoryInfo) -> History? {
        guard let entity = NSEntityDescription.entity(forEntityName: History.entityName, in: self.context) else { return nil }
        
        let newHistory = History(entity: entity, insertInto: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Travel.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", historyInfo.travelId as CVarArg)
        
        guard let travels = fetch(fetchRequest) as? [Travel],
              
              let fetchedTravel = travels.first else { return nil }
        
        newHistory.travel = fetchedTravel
        newHistory.id = historyInfo.id
        newHistory.isIncome = historyInfo.isIncome
        newHistory.title = historyInfo.title
        newHistory.memo = historyInfo.memo
        newHistory.amount = historyInfo.amount
        newHistory.categoryState = historyInfo.category
        newHistory.date = historyInfo.date
        newHistory.image = historyInfo.image
        newHistory.isPrepare = historyInfo.isPrepare ?? false
        newHistory.isCard = historyInfo.isCard ?? false
        
        return newHistory
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

    func setupTravelInfo(travelInfo: TravelInfo, completion: @escaping (Travel?) -> Void) {
        guard let entity = NSEntityDescription.entity(forEntityName: Travel.entityName, in: self.context) else {
            completion(nil)
            return
        }
        let newTravel = Travel(entity: entity, insertInto: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", travelInfo.countryName)
        
        guard let countries = fetch(fetchRequest) as? [Country], let fetchedCountry = countries.first else {
            completion(nil)
            return
        }
        
        newTravel.country = fetchedCountry
        newTravel.id = travelInfo.id
        newTravel.title = travelInfo.title
        newTravel.memo = travelInfo.memo
        newTravel.startDate = travelInfo.startDate
        newTravel.endDate = travelInfo.endDate
        newTravel.budget = travelInfo.budget
        newTravel.coverImage = travelInfo.coverImage
        
        if let lastUpdated = fetchedCountry.lastUpdated, isExchangeRateOutdated(lastUpdated: lastUpdated) {
            dataLoader?.requestExchangeRate(url: exchangeRateAPIurl) { [weak self] (result) in
                guard let currencyCode = fetchedCountry.currencyCode else { return }
                
                switch result {
                    
                case .success(let data):
                    
                    let newExchangeRate = data.rates[currencyCode] ?? fetchedCountry.exchangeRate
                    let newLastUpdated = (data.date + "-00-00-00").convertToDate()
                    
                    newTravel.exchangeRate = newExchangeRate
                    
                    if let countryName = fetchedCountry.name,
                        let flagImage = fetchedCountry.flagImage,
                        let currencyCode = fetchedCountry.currencyCode,
                        self?.updateObject(updatedObjectInfo: CountryInfo(name: countryName, lastUpdated: newLastUpdated, flagImage: flagImage, exchangeRate: newExchangeRate, currencyCode: currencyCode)) != nil {
                        print("환율 정보 업데이트 성공")
                    }
                    
                case .failure(let error):
                    print("Network error")
                    print(error.localizedDescription)
                    newTravel.exchangeRate = fetchedCountry.exchangeRate
                }
                
                completion(newTravel)
            }
        } else {
            newTravel.exchangeRate = fetchedCountry.exchangeRate
            completion(newTravel)
        }
    }

    func isExchangeRateOutdated(lastUpdated: Date) -> Bool {
        return !Calendar.current.isDateInToday(lastUpdated)
    }
}

// MARK: - Core Data Retrieving support

extension PersistenceManager {
    func fetchAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        if T.self == Country.self {
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSort]
        } else if T.self == Travel.self {
            let startDateSort = NSSortDescriptor(key: "startDate", ascending: true)
            request.sortDescriptors = [startDateSort]
        } else if T.self == History.self {
            let dateSort = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [dateSort]
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
}

// MARK: - Core Data Updating support

extension PersistenceManager {
    func updateObject<T>(updatedObjectInfo: T) -> DataModelProtocol? {
        var updatedObject: DataModelProtocol?
        
        if let updatedTravelInfo = updatedObjectInfo as? TravelInfo,
            let updatedTravel =  updateTravel(travelInfo: updatedTravelInfo) {
            updatedObject = updatedTravel
        } else if let updatedCountryInfo = updatedObjectInfo as? CountryInfo,
            let updatedCountry = updateCountry(countryInfo: updatedCountryInfo) {
            updatedObject = updatedCountry
        } else if let updatedHistoryInfo = updatedObjectInfo as? HistoryInfo,
            let updatedHistory = updateHistory(historyInfo: updatedHistoryInfo) {
            updatedObject = updatedHistory
        }
        
        return updatedObject
    }

    private func updateHistory(historyInfo: HistoryInfo) -> History? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: History.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", historyInfo.id as CVarArg)
        
        do {
            let anys = try self.context.fetch(fetchRequest)
            let objectUpdate = anys[0] as? NSManagedObject
            
            objectUpdate?.setValue(historyInfo.amount, forKey: "amount")
            objectUpdate?.setValue(historyInfo.category.rawValue, forKey: "category")
            objectUpdate?.setValue(historyInfo.date, forKey: "date")
            objectUpdate?.setValue(historyInfo.image, forKey: "image")
            objectUpdate?.setValue(historyInfo.isCard, forKey: "isCard")
            objectUpdate?.setValue(historyInfo.isPrepare, forKey: "isPrepare")
            objectUpdate?.setValue(historyInfo.memo, forKey: "memo")
            objectUpdate?.setValue(historyInfo.title, forKey: "title")
            
            try self.context.save()
            
            let histories = fetch(fetchRequest) as? [History]
            let updatedHistory = histories?.first
            
            return updatedHistory
        } catch {
            print("updateHistory Error")
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func updateTravel(travelInfo: TravelInfo) -> Travel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Travel.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", travelInfo.id as CVarArg)
        
        do {
            let anys = try self.context.fetch(fetchRequest)
            let objectUpdate = anys[0] as? NSManagedObject

            objectUpdate?.setValue(travelInfo.title, forKey: "title")
            objectUpdate?.setValue(travelInfo.memo, forKey: "memo")
            objectUpdate?.setValue(travelInfo.startDate, forKey: "startDate")
            objectUpdate?.setValue(travelInfo.endDate, forKey: "endDate")
            objectUpdate?.setValue(travelInfo.budget, forKey: "budget")
            objectUpdate?.setValue(travelInfo.coverImage, forKey: "coverImage")
            
            try self.context.save()
            
            let travels = fetch(fetchRequest) as? [Travel]
            let updatedTravel = travels?.first
            
            return updatedTravel
        } catch {
            print("updateTravel Error")
            print(error.localizedDescription)
            return nil
        }
    }

    private func updateCountry(countryInfo: CountryInfo) -> Country? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", countryInfo.name)
        
        do {
            let anys = try self.context.fetch(fetchRequest)
            let objectUpdate = anys[0] as? NSManagedObject
            
            objectUpdate?.setValue(countryInfo.lastUpdated, forKey: "lastUpdated")
            objectUpdate?.setValue(countryInfo.exchangeRate, forKey: "exchangeRate")
            
            try self.context.save()
            
            let countries = fetch(fetchRequest) as? [Country]
            let updatedCountry = countries?.first
            
            return updatedCountry
        } catch {
            print("updateCountry Error")
            print(error.localizedDescription)
            return nil
        }
    }
}

// MARK: - Core Data Deleting support

extension PersistenceManager {
    func delete<T>(deletingObject: T) -> Bool {
        
        if let travelObject = deletingObject as? Travel {
            self.context.delete(travelObject)
        } else if let countryObject = deletingObject as? Country {
            self.context.delete(countryObject)
        } else if let historyObject = deletingObject as? History {
            self.context.delete(historyObject)
        }
        
        do {
            try context.save()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

// MARK: - Core Data Counting support

extension PersistenceManager {
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
