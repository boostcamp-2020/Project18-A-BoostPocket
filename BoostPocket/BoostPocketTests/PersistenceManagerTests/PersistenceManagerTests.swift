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
        let createdObject = persistenceManagerStub.createObject(newObjectInfo: countryInfo)
        let createdCountry = createdObject as? Country
        
        let fetchedCounties = persistenceManagerStub.fetchAll(request: Country.fetchRequest())
        
        XCTAssertNotNil(createdObject)
        XCTAssertNotNil(createdCountry)
        XCTAssertNotEqual(fetchedCounties, [])
        XCTAssertEqual(fetchedCounties.first, createdCountry)
    }
    
/*
    func test_persistenceManager_fetch() {
        let createdCountry = persistenceManagerStub.createObject(newObjectInfo: countryInfo)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", countryName)
        
        let fetchResult = persistenceManagerStub.fetch(fetchRequest)
        XCTAssertNotNil(fetchResult)
        XCTAssertEqual(fetchResult?.first, createdCountry)
    }
*/
    
    func test_persistenceManager_delete() {
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        
        guard let createdCountryObject = persistenceManagerStub.createObject(newObjectInfo: countryInfo),
            let createdCountry = createdCountryObject as? Country,
            let createdTravelObject = persistenceManagerStub.createObject(newObjectInfo: countryInfo),
            let createdTravel = createdTravelObject as? Travel
            else { return }
                
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()).first,
                       createdCountry)
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()).first,
        createdTravel)
        
        persistenceManagerStub.delete(object: createdCountry)
        persistenceManagerStub.delete(object: createdTravel)
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
    }
    
    func test_persistenceManager_count() {
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 0)
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo)
        persistenceManagerStub.createObject(newObjectInfo: travelInfo)
        persistenceManagerStub.createObject(newObjectInfo: travelInfo)
        
        XCTAssertNotNil(persistenceManagerStub.count(request: Travel.fetchRequest()))
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 3)
    }
}
