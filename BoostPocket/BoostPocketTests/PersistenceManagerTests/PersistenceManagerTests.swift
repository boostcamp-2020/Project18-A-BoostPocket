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
    
    let countryName = "test name"
    let lastUpdated = Date()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    
    override func setUpWithError() throws {
        persistenceManagerStub = PersistenceManagerStub()
        countryInfo = CountryInfo(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryInfo = nil
    }

    func test_persistenceManager_createCountry() {
        let createdCountry = persistenceManagerStub.createCountry(countryInfo: countryInfo)
        let fetchedCounties = persistenceManagerStub.fetch(request: Country.fetchRequest())
        
        XCTAssertNotNil(createdCountry)
        XCTAssertNotEqual(fetchedCounties, [])
        XCTAssertEqual(fetchedCounties.first, createdCountry)
    }
    
    func test_persistenceManager_delete() { }

}
