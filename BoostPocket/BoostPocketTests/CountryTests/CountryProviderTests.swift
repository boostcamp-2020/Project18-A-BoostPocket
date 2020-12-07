//
//  PersistenceManagerTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import NetworkManager
@testable import BoostPocket

class CountryProviderTests: XCTestCase {
    
    var persistenceManagerStub: PersistenceManagable!
    var countryProviderStub: CountryProviderStub!
    
    let countryName = "test name"
    let lastUpdated = "2019-08-23-12-01-33".convertToDate()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    let identifier = "ko_KR"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        countryProviderStub = CountryProviderStub(persistenceManager: persistenceManagerStub)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryProviderStub = nil
    }

    func test_countryProvider_fetchCountries() {
        let expectation = XCTestExpectation(description: "Successfully Created Country")
        
        XCTAssertEqual(countryProviderStub.fetchCountries(), [])
        
        countryProviderStub.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier) { (country) in
            XCTAssertNotNil(country)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotEqual(countryProviderStub.fetchCountries(), [])
    }
    
    func test_countryProvider_createCountry() {
        let expectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        countryProviderStub.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier) { (country) in
            XCTAssertNotNil(country)
            createdCountry = country
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(createdCountry)
        XCTAssertEqual(createdCountry?.name, countryName)
        XCTAssertEqual(createdCountry?.lastUpdated, lastUpdated)
        XCTAssertEqual(createdCountry?.flagImage, flagImage)
        XCTAssertEqual(createdCountry?.exchangeRate, exchangeRate)
        XCTAssertEqual(createdCountry?.currencyCode, currencyCode)
    }

}
