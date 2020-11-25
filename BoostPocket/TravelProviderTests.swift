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
    var countryProviderStub: CountryProvidable!
    var travelProviderStub: TravelProvidable!
    
    let countryName = "대한민국"
    let lastUpdated = Date()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"

    override func setUpWithError() throws {
        persistenceManagerStub = PersistenceManagerStub()
        countryProviderStub = CountryProvider(persistenceManager: persistenceManagerStub)
        travelProviderStub = TravelProvider(persistenceManager: persistenceManagerStub)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        travelProviderStub = nil
    }

    func test_travelProvider_createTravel() {
        
        countryProviderStub.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        let createdTravel = travelProviderStub.createTravel(countryName: countryName)
        
        XCTAssertNotNil(createdTravel)
        XCTAssertEqual(createdTravel?.title, countryName)
        XCTAssertEqual(createdTravel?.country?.name, countryName)
    }
    
    func test_travelProvider_fetchTravels() {
        
        XCTAssertEqual(travelProviderStub.fetchTravels(), [])
        countryProviderStub.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        travelProviderStub.createTravel(countryName: countryName)
        
        XCTAssertNotEqual(travelProviderStub.fetchTravels(), [])
        let travel = travelProviderStub.fetchTravels().first
        
        XCTAssertEqual(travel?.title, countryName)
        XCTAssertEqual(travel?.exchangeRate, exchangeRate)
    }

}
