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
    var dataLoader: DataLoader?
    
    let id = UUID()
    let memo = ""
    let startDate = Date()
    let endDate = Date()
    let coverImage = Data()
    let budget = Double()
    let exchangeRate = 1.5
    let countryName = "대한민국"
    let lastUpdated = "2019-08-23".convertToDate()
    let flagImage = Data()
    let currencyCode = "KRW"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        countryInfo = CountryInfo(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        travelInfo = TravelInfo(countryName: countryName, id: id, title: countryName, memo: memo, startDate: startDate, endDate: endDate, coverImage: coverImage, budget: budget, exchangeRate: exchangeRate)
        
        self.dataLoader = dataLoader
    }
    
    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryInfo = nil
        travelInfo = nil
    }
    
    func test_persistenceManager_createObject() {
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        let fetchedCounties = persistenceManagerStub.fetchAll(request: Country.fetchRequest())
        XCTAssertNotEqual(fetchedCounties, [])
        XCTAssertEqual(fetchedCounties.first, createdCountry)
        
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
        
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        XCTAssertNotEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        XCTAssertNotEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
    }
    
    func test_persistenceManager_fetch() {
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", countryInfo.name)
        
        let fetchedCountry = persistenceManagerStub.fetch(fetchRequest) as? [Country]
        XCTAssertNotNil(fetchedCountry)
        XCTAssertEqual(fetchedCountry?.first, createdCountry)
    }
    
    func test_persistenceManager_updateObject() {
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Travel Country")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        let newLastUpdated = "2020-12-25".convertToDate()
        let newExchagneRate = 12.0
        countryInfo = CountryInfo(name: countryName, lastUpdated: newLastUpdated, flagImage: flagImage, exchangeRate: newExchagneRate, currencyCode: currencyCode)
        
        travelInfo = TravelInfo(countryName: countryName, id: id, title: countryName, memo: "updated memo", startDate: startDate, endDate: endDate, coverImage: coverImage, budget: budget, exchangeRate: exchangeRate)
        
        let updatedCountry = persistenceManagerStub.updateObject(updatedObjectInfo: countryInfo) as? Country
        let updatedTravel = persistenceManagerStub.updateObject(updatedObjectInfo: travelInfo) as? Travel
        
        XCTAssertNotNil(updatedCountry)
        XCTAssertEqual(createdCountry?.lastUpdated, newLastUpdated)
        XCTAssertEqual(createdCountry?.exchangeRate, newExchagneRate)
        
        XCTAssertNotNil(updatedTravel)
        XCTAssertEqual(createdTravel?.memo, "updated memo")
    }
    
    func test_persistenceManager_delete() {
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Travel Country")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()).first, createdCountry)
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()).first, createdTravel)
        
        XCTAssertTrue(persistenceManagerStub.delete(deletingObject: createdTravel))
        XCTAssertTrue(persistenceManagerStub.delete(deletingObject: createdCountry))
        
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
    }
    
    func test_persistenceManager_count() {
        XCTAssertEqual(persistenceManagerStub.count(request: Country.fetchRequest()), 0)
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 0)
        
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Travel Country")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        XCTAssertEqual(persistenceManagerStub.count(request: Country.fetchRequest()), 1)
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 1)
    }
}
