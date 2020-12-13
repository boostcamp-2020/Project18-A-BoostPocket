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
    func updateObject<T>(updatedObjectInfo: T, completion: @escaping (DataModelProtocol?) -> Void)
    func delete<T>(deletingObject: T) -> Bool
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int?
    func setupTravelInfo(travelInfo: TravelInfo, completion: @escaping (Travel?) -> Void)
    @discardableResult func saveContext() -> Bool
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
                
                createObject(newObjectInfo: CountryInfo(name: countryName, lastUpdated: date, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier)) { _ in }
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
    @discardableResult
    func saveContext() -> Bool {
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch let saveError {
                print("saveContext 실패: \(saveError)")
                return false
            }
        }
        return true
    }
}

// MARK: - Core Data Creating support

extension PersistenceManager {
    func createObject<T>(newObjectInfo: T, completion: @escaping (DataModelProtocol?) -> Void) {
        var createdObject: DataModelProtocol?
        
        if let newCountryInfo = newObjectInfo as? CountryInfo {
            createdObject = setupCountryInfo(countryInfo: newCountryInfo)
        } else if let newTravelInfo = newObjectInfo as? TravelInfo {
            setupTravelInfo(travelInfo: newTravelInfo) { [weak self] newTravel in
                createdObject = newTravel
                
                guard let self = self, self.saveContext() else {
                    completion(nil)
                    return
                }
                
                completion(createdObject)
            }
        } else if let newHistoryInfo = newObjectInfo as? HistoryInfo {
            createdObject = setupHistoryInfo(historyInfo: newHistoryInfo)
            guard saveContext() else {
                completion(nil)
                return
            }
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
        
        newCountry.identifier = countryInfo.identifier
        newCountry.name = countryInfo.name
        newCountry.lastUpdated = countryInfo.lastUpdated
        newCountry.flagImage = countryInfo.flagImage
        newCountry.exchangeRate = countryInfo.exchangeRate
        newCountry.currencyCode = countryInfo.currencyCode
        
        return newCountry
    }

    func setupTravelInfo(travelInfo: TravelInfo, completion: @escaping (Travel?) -> Void) {
        guard let entity = NSEntityDescription.entity(forEntityName: Travel.entityName, in: self.context) else {
            print("setupTravelInfo - Travel Entity 불러오기 실패")
            completion(nil)
            return
        }
        
        let newTravel = Travel(entity: entity, insertInto: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", travelInfo.countryName)
        
        guard let countries = fetch(fetchRequest) as? [Country], let fetchedCountry = countries.first else {
            print("setupTravelInfo - 국가 \(travelInfo.countryName)을 찾지 못했습니다")
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
            dataLoader?.requestExchangeRate(url: exchangeRateAPIurl) { [weak self] result in
                guard let currencyCode = fetchedCountry.currencyCode else { return }
                
                switch result {
                case .success(let data):
                    print("setupTravelInfo - 새로운 환율정보 네트워크 응답 성공")
                    let newExchangeRate = data.rates[currencyCode] ?? fetchedCountry.exchangeRate
                    let newLastUpdated = data.date.convertToDate()
                    
                    newTravel.exchangeRate = newExchangeRate
                    
                    if let countryName = fetchedCountry.name, let flagImage = fetchedCountry.flagImage, let currencyCode = fetchedCountry.currencyCode, let identifier = fetchedCountry.identifier {
                        self?.updateObject(updatedObjectInfo: CountryInfo(name: countryName, lastUpdated: newLastUpdated, flagImage: flagImage, exchangeRate: newExchangeRate, currencyCode: currencyCode, identifier: identifier)) { result in
                            if let _ = result {
                                print("setupTravelInfo - 새로운 환율정보 업데이트 성공")
                                completion(newTravel)
                            } else {
                                print("setupTravelInfo - 새로운 환율정보 업데이트 실패")
                                completion(newTravel)
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("setupTravelInfo - 새로운 환율정보 네트워크 응답 실패")
                    print(error.localizedDescription)
                    newTravel.exchangeRate = fetchedCountry.exchangeRate
                    completion(newTravel)
                }
            }
        } else {
            print("setupTravelInfo - 환율 정보가 최신입니다")
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
            // print("fetchAll 성공")
            return fetchedResult
        } catch let fetchAllError {
            print("fetchAll 실패: \(fetchAllError)")
            return []
        }
    }

    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]? {
        do {
            let fetchResult = try self.context.fetch(request)
            print("fetch 성공")
            return fetchResult
        } catch let fetchError {
            print("fetch 실패: \(fetchError)")
            return nil
        }
    }
    
    func fetchTravel(withId id: UUID) -> Travel? {
        let fetchRequest = NSFetchRequest<Travel>(entityName: Travel.entityName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let travels = try context.fetch(fetchRequest)
            return travels.first
        } catch let fetchError {
            print("fetchTravel 실패: \(fetchError)")
        }
        
        return nil
    }
    
    func fetchHistory(withId id: UUID) -> History? {
        let fetchRequest = NSFetchRequest<History>(entityName: History.entityName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let histories = try context.fetch(fetchRequest)
            return histories.first
        } catch let fetchError {
            print("fetchHistory 실패: \(fetchError)")
        }
        
        return nil
    }
    
    func fetchCountry(withName name: String) -> Country? {
        let fetchRequest = NSFetchRequest<Country>(entityName: Country.entityName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let countries = try context.fetch(fetchRequest)
            return countries.first
        } catch let fetchError {
            print("fetchCountry 실패: \(fetchError)")
        }
        
        return nil
    }
}

// MARK: - Core Data Updating support

extension PersistenceManager {
    func updateObject<T>(updatedObjectInfo: T, completion: @escaping (DataModelProtocol?) -> Void) {
        var updatedObject: DataModelProtocol?
        
        if let updatedTravelInfo = updatedObjectInfo as? TravelInfo,
            let updatedTravel = updateTravel(travelInfo: updatedTravelInfo) {
            updatedObject = updatedTravel
            completion(updatedObject)
        } else if let updatedCountryInfo = updatedObjectInfo as? CountryInfo,
            let updatedCountry = updateCountry(countryInfo: updatedCountryInfo) {
            updatedObject = updatedCountry
            completion(updatedObject)
        } else if let updatedHistoryInfo = updatedObjectInfo as? HistoryInfo,
            let updatedHistory = updateHistory(historyInfo: updatedHistoryInfo) {
            updatedObject = updatedHistory
            completion(updatedObject)
        } else {
            completion(nil)
        }
    }

    private func updateHistory(historyInfo: HistoryInfo) -> History? {
        guard let updatingHistory = fetchHistory(withId: historyInfo.id) else { return nil }
        
        updatingHistory.amount = historyInfo.amount
        updatingHistory.category = historyInfo.category.rawValue
        updatingHistory.date = historyInfo.date
        updatingHistory.image = historyInfo.image
        updatingHistory.isCard = historyInfo.isCard ?? false
        updatingHistory.isPrepare = historyInfo.isPrepare ?? false
        updatingHistory.memo = historyInfo.memo
        updatingHistory.title = historyInfo.title
        
        guard saveContext() else { return nil }
        return updatingHistory
    }
    
    private func updateTravel(travelInfo: TravelInfo) -> Travel? {
        guard let updatingTravel = fetchTravel(withId: travelInfo.id) else { return nil }
        
        updatingTravel.title = travelInfo.title
        updatingTravel.memo = travelInfo.memo
        updatingTravel.startDate = travelInfo.startDate
        updatingTravel.endDate = travelInfo.endDate
        updatingTravel.coverImage = travelInfo.coverImage
        
        guard saveContext() else { return nil }
        return updatingTravel
    }
    
    private func updateCountry(countryInfo: CountryInfo) -> Country? {
        guard let updatingCountry = fetchCountry(withName: countryInfo.name) else { return nil }
        
        updatingCountry.lastUpdated = countryInfo.lastUpdated
        updatingCountry.exchangeRate = countryInfo.exchangeRate

        guard saveContext() else { return nil }
        return updatingCountry
    }
}

// MARK: - Core Data Deleting support

extension PersistenceManager {
    func delete<T>(deletingObject: T) -> Bool {
        if let travelObject = deletingObject as? Travel, deleteHistories(of: travelObject) {
            self.context.delete(travelObject)
        } else if let countryObject = deletingObject as? Country {
            self.context.delete(countryObject)
        } else if let historyObject = deletingObject as? History {
            self.context.delete(historyObject)
        }
        
        guard saveContext() else { return false }
        return true
    }
    
    func deleteHistories(of travel: Travel) -> Bool {
        let historySet = travel.mutableSetValue(forKey: "history")
        
        for history in historySet {
            guard let historyObject = history as? NSManagedObject else { return false }
            context.delete(historyObject)
        }
        
        guard saveContext() else { return false }
        return true
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
