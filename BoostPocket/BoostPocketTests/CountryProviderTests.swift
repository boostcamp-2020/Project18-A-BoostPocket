//
//  PersistenceManagerTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest

class CountryProviderTests: XCTestCase {
    
    var persistenceManagerStub: PersistenceManagable!
    var countryProviderStub: CountryProvidable!
    
    override func setUpWithError() throws {
        persistenceManagerStub = PersistenceManagerStub()
        countryProviderStub = CountryProviderStub(persistenceManager: persistenceManagerStub)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
    }
    
    func test_fetch_empty_country_list() {
        // given: none
        
        // when
        let fetchedCountries = countryProviderStub.fetchCountries()
        
        // then
        XCTAssertEqual(fetchedCountries, [])
    }
    
    func test_create_new_country() {
        // given
        let name = "test name"
        let lastUpdated = Date()
        let flagImage = Data()
        let exchangeRate = 1.0
        let currencyCode = "test currency code"
        
        // when
        let createdCountry = countryProviderStub.createCountry(name: name, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        
        // then
        XCTAssertNotNil(createdCountry)
        XCTAssertEqual(createdCountry?.name, name)
        XCTAssertEqual(createdCountry?.lastUpdated, lastUpdated)
        XCTAssertEqual(createdCountry?.flagImage, flagImage)
        XCTAssertEqual(createdCountry?.exchangeRate, exchangeRate)
        XCTAssertEqual(createdCountry?.currencyCode, currencyCode)
    }

}
