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
    
    let countryName = "대한민국"
    let lastUpdated = Date()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"

    override func setUpWithError() throws {
        persistenceManagerStub = PersistenceManagerStub()
        countryProvider = CountryProvider(persistenceManager: persistenceManagerStub)
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryProvider = nil
        travelProvider = nil
    }

    func test_travelProvider_createTravel() {
        countryProvider.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        let createdTravel = travelProvider.createTravel(countryName: countryName)
        
        XCTAssertNotNil(createdTravel)
        XCTAssertEqual(createdTravel?.title, countryName)
        XCTAssertEqual(createdTravel?.country?.name, countryName)
    }
    
//    func test_travelProvider_fetchTravels() {
//
//        XCTAssertEqual(travelProvider.fetchTravels(), [])
//        countryProvider.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
//        travelProvider.createTravel(countryName: countryName)
//
//        XCTAssertNotEqual(travelProvider.fetchTravels(), [])
//        let travel = travelProvider.fetchTravels().first
//
//        XCTAssertEqual(travel?.title, countryName)
//        XCTAssertEqual(travel?.exchangeRate, exchangeRate)
//    }
}
