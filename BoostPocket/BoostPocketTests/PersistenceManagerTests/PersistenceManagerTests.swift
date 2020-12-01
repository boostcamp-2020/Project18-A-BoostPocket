//
//  PersistenceManagerTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import CoreData
import NetworkManager
@testable import BoostPocket

class PersistenceManagerTests: XCTestCase {
    var persistenceManagerStub: PersistenceManagable!
    var countryInfo: CountryInfo!
    var travelInfo: TravelInfo!
    
    let id = UUID()
    let memo = ""
    let startDate = Date()
    let endDate = Date()
    let coverImage = Data()
    let budget = Double()
    let exchangeRate = 1.5
    let countryName = "test name"
    let lastUpdated = Date()
    let flagImage = Data()
    let currencyCode = "test code"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        countryInfo = CountryInfo(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        travelInfo = TravelInfo(countryName: countryName, id: id, title: countryName, memo: memo, startDate: startDate, endDate: endDate, coverImage: coverImage, budget: budget, exchangeRate: exchangeRate)
    }
    
    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryInfo = nil
        travelInfo = nil
    }
    
    func test_persistenceManager_createObject() {
        let createdCountry = persistenceManagerStub.createObject(newObjectInfo: countryInfo) as? Country
        XCTAssertNotNil(createdCountry)
        
        let fetchedCounties = persistenceManagerStub.fetchAll(request: Country.fetchRequest())
        XCTAssertNotEqual(fetchedCounties, [])
        XCTAssertEqual(fetchedCounties.first, createdCountry)
        
        let createdTravel = persistenceManagerStub.createObject(newObjectInfo: travelInfo) as? Travel
        XCTAssertNotNil(createdTravel)
        
        let fetchedTravels = persistenceManagerStub.fetchAll(request: Travel.fetchRequest())
        XCTAssertNotEqual(fetchedTravels, [])
        XCTAssertEqual(fetchedTravels.first, createdTravel)
    }
    
    func test_persistenceManager_isExchangeRateOutdated() {
        let dateString: String = "2020-11-30 10:20:00"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        let yeaterday: Date = dateFormatter.date(from: dateString)!
        let today = Date()
        
        XCTAssertFalse(persistenceManagerStub.isExchangeRateOutdated(lastUpdated: today))
        XCTAssertTrue(persistenceManagerStub.isExchangeRateOutdated(lastUpdated: yeaterday))
    }
    
    func test_persistenceManager_fetchAll() {
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        
        let createdCountry = persistenceManagerStub.createObject(newObjectInfo: countryInfo) as? Country
        XCTAssertNotNil(createdCountry)
        
        let createdTravel = persistenceManagerStub.createObject(newObjectInfo: travelInfo) as? Travel
        XCTAssertNotNil(createdTravel)
        
        XCTAssertNotEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()).first, createdTravel)
    }
    
    func test_persistenceManager_fetch() {
        let createdCountry = persistenceManagerStub.createObject(newObjectInfo: countryInfo) as? Country
        XCTAssertNotNil(createdCountry)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", countryInfo.name)
        
        let fetchedCountry = persistenceManagerStub.fetch(fetchRequest) as? [Country]
        XCTAssertNotNil(fetchedCountry)
        XCTAssertEqual(fetchedCountry?.first, createdCountry)
    }
    
    func test_persistenceManager_updateObject() {
        let createdCountry = persistenceManagerStub.createObject(newObjectInfo: countryInfo) as? Country
        let createdTravel = persistenceManagerStub.createObject(newObjectInfo: travelInfo) as? Travel
        dump(createdTravel)
        
        XCTAssertNotNil(createdCountry)
        XCTAssertNotNil(createdTravel)
        
        travelInfo = TravelInfo(countryName: countryName, id: id, title: countryName, memo: "updated memo", startDate: startDate, endDate: endDate, coverImage: coverImage, budget: budget, exchangeRate: exchangeRate)
        
        let updatedTravel = persistenceManagerStub.updateObject(updatedObjectInfo: travelInfo) as? Travel
        dump(updatedTravel)
        
        XCTAssertNotNil(updatedTravel)
        XCTAssertEqual(updatedTravel?.memo, "updated memo")
    }
    
    func test_persistenceManager_delete() {
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        
        let createdCountry = persistenceManagerStub.createObject(newObjectInfo: countryInfo) as? Country
        let createdTravel = persistenceManagerStub.createObject(newObjectInfo: travelInfo) as? Travel
        
        XCTAssertNotNil(createdCountry)
        XCTAssertNotNil(createdTravel)
        
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()).first, createdCountry)
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()).first, createdTravel)
        
        let isTravelDelted = persistenceManagerStub.delete(deletingObject: createdTravel)
        let isCountryDeleted = persistenceManagerStub.delete(deletingObject: createdCountry)
        
        XCTAssertTrue(isCountryDeleted)
        XCTAssertTrue(isTravelDelted)
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
    }
    
    func test_persistenceManager_count() {
        XCTAssertNotNil(persistenceManagerStub.createObject(newObjectInfo: countryInfo) as? Country)
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 0)
        
        XCTAssertNotNil(persistenceManagerStub.createObject(newObjectInfo: travelInfo))
        XCTAssertNotNil(persistenceManagerStub.createObject(newObjectInfo: travelInfo))
        XCTAssertNotNil(persistenceManagerStub.createObject(newObjectInfo: travelInfo))
        XCTAssertNotNil(persistenceManagerStub.count(request: Travel.fetchRequest()))
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 3)
    }
}
