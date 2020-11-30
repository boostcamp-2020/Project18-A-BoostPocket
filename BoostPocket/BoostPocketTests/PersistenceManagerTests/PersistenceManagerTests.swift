//
//  PersistenceManagerTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import CoreData
@testable import BoostPocket

class PersistenceManagerTests: XCTestCase {
    
    var persistenceManagerStub: PersistenceManagable!
    var countryInfo: CountryInfo!
    var travelInfo: TravelInfo!
    
    let countryName = "test name"
    let lastUpdated = Date()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    
    override func setUpWithError() throws {
        persistenceManagerStub = PersistenceManagerStub()
        countryInfo = CountryInfo(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        travelInfo = TravelInfo(countryName: countryName)
    }
    
    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryInfo = nil
        travelInfo = nil
    }
    
    func test_persistenceManager_createObject() {
        let createdCountryObject = persistenceManagerStub.createObject(newObjectInfo: countryInfo)
        let createdCountry = createdCountryObject as? Country
        let fetchedCounties = persistenceManagerStub.fetchAll(request: Country.fetchRequest())
        
        XCTAssertNotNil(createdCountryObject)
        XCTAssertNotNil(createdCountry)
        XCTAssertNotEqual(fetchedCounties, [])
        XCTAssertEqual(fetchedCounties.first, createdCountry)
        
        let createdTravelObject = persistenceManagerStub.createObject(newObjectInfo: travelInfo)
        let createdTravel = createdTravelObject as? Travel
        let fetchedTravels = persistenceManagerStub.fetchAll(request: Travel.fetchRequest())
        
        XCTAssertNotNil(createdTravelObject)
        XCTAssertNotNil(createdTravel)
        XCTAssertNotEqual(fetchedTravels, [])
        XCTAssertEqual(fetchedTravels.first, createdTravel)
    }
    
    func test_persistenceManager_fetchAll() {
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        
        let createdCountryObject = persistenceManagerStub.createObject(newObjectInfo: countryInfo)
        let createdCountry = createdCountryObject as? Country
        XCTAssertNotNil(createdCountryObject)
        XCTAssertNotNil(createdCountry)
        
        let createdTravelObject = persistenceManagerStub.createObject(newObjectInfo: travelInfo)
        let createdTravel = createdTravelObject as? Travel
        XCTAssertNotNil(createdTravelObject)
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
    
    func test_persistenceManager_delete() {
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        
        let createdCountryObject = persistenceManagerStub.createObject(newObjectInfo: countryInfo)
        let createdCountry = createdCountryObject as? Country
        let createdTravelObject = persistenceManagerStub.createObject(newObjectInfo: travelInfo)
        let createdTravel = createdTravelObject as? Travel
        
        XCTAssertNotNil(createdCountryObject)
        XCTAssertNotNil(createdCountry)
        XCTAssertNotNil(createdTravelObject)
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
        let createdCountryObject = persistenceManagerStub.createObject(newObjectInfo: countryInfo)
        XCTAssertNotNil(createdCountryObject)
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 0)
        
        XCTAssertNotNil(persistenceManagerStub.createObject(newObjectInfo: travelInfo))
        XCTAssertNotNil(persistenceManagerStub.createObject(newObjectInfo: travelInfo))
        XCTAssertNotNil(persistenceManagerStub.createObject(newObjectInfo: travelInfo))
        
        XCTAssertNotNil(persistenceManagerStub.count(request: Travel.fetchRequest()))
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 3)
    }
}
