//
//  TravelProviderTests.swift
//  BoostPocketTests
//
//  Created by 이승진 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class TravelProviderTests: XCTestCase {
    
    var persistenceManagerStub: PersistenceManagable!
    var countryProvider: CountryProvidable!
    var travelProvider: TravelProvidable!
    var countryInfo: CountryInfo!
    var country: Country!

    let countryName = "대한민국"
    let lastUpdated = Date()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    
    override func setUpWithError() throws {
        persistenceManagerStub = PersistenceManagerStub()
        countryProvider = CountryProvider(persistenceManager: persistenceManagerStub)
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
        
        country = countryProvider.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        countryInfo = CountryInfo(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
    }
    
    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryProvider = nil
        travelProvider = nil
        countryInfo = nil
    }
    
    func test_travelProvider_createTravel() {
        let createdTravel = travelProvider.createTravel(countryName: countryName)
        
        XCTAssertNotNil(createdTravel)
        XCTAssertEqual(createdTravel?.title, countryName)
        XCTAssertEqual(createdTravel?.country?.name, countryName)
    }
    
    func test_travelProvider_fetchTravels() {
        let createdTravel = travelProvider.createTravel(countryName: countryName)
        XCTAssertNotNil(createdTravel)
        
        let fetchedTravels = travelProvider.fetchTravels()
        XCTAssertNotEqual(fetchedTravels, [])
        
        let fetchedTravel = travelProvider.fetchTravels().first
        XCTAssertNotNil(fetchedTravel)
        XCTAssertEqual(fetchedTravel?.title, countryName)
        XCTAssertEqual(fetchedTravel?.exchangeRate, exchangeRate)
    }
    
    func test_travelPrpvider_updateTravel() {
        XCTAssertNotNil(persistenceManagerStub.createObject(newObjectInfo: countryInfo) as? Country)
        
        let createdTravel = travelProvider.createTravel(countryName: countryName)
        XCTAssertNotNil(createdTravel)
         
        let travelInfo = TravelInfo(countryName: countryName, id: (createdTravel?.id)!, title: "updated title", memo: (createdTravel?.memo)!, startDate: (createdTravel?.startDate)!, endDate: (createdTravel?.endDate)!, coverImage: (createdTravel?.coverImage)!, budget: createdTravel!.budget, exchangeRate: createdTravel!.exchangeRate)
        
        XCTAssertNotNil(travelProvider.updateTravel(updatedTravelInfo: travelInfo))
        XCTAssertEqual(travelProvider.fetchTravels().first, createdTravel)
        XCTAssertEqual(travelProvider.fetchTravels().first?.title, "updated title")
    }
    
    func test_travelProvider_deleteTravel() {
        XCTAssertEqual(travelProvider.fetchTravels(), [])
        
        let createdTravel = travelProvider.createTravel(countryName: countryName)
        XCTAssertNotNil(createdTravel)
        
        let fetchedTravels = travelProvider.fetchTravels()
        XCTAssertNotEqual(fetchedTravels, [])
        
        let fetchedTravel = travelProvider.fetchTravels().first
        XCTAssertNotNil(fetchedTravel)
        
        let isDeleted = travelProvider.deleteTravel(id: fetchedTravel?.id ?? UUID())
        XCTAssertTrue(isDeleted)
        XCTAssertEqual(travelProvider.fetchTravels(), [])
    }
}
