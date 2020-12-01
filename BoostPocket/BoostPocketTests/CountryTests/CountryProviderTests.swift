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
    var countryProviderStub: CountryProvidable!
    
    let countryName = "test name"
    let lastUpdated = Date()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        countryProviderStub = CountryProvider(persistenceManager: persistenceManagerStub)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryProviderStub = nil
    }
    
    func test_countryProvider_fetchCountries() {
        XCTAssertEqual(countryProviderStub.fetchCountries(), [])
        
        let createdCountry = countryProviderStub.createCountry(name: countryName,
                                                               lastUpdated: lastUpdated,
                                                               flagImage: flagImage,
                                                               exchangeRate: exchangeRate,
                                                               currencyCode: currencyCode)
        
        XCTAssertNotNil(createdCountry)
        XCTAssertNotEqual(countryProviderStub.fetchCountries(), [])
        
        XCTAssertEqual(countryProviderStub.fetchCountries().first?.name, countryName)
        XCTAssertEqual(countryProviderStub.fetchCountries().first?.lastUpdated, lastUpdated)
        XCTAssertEqual(countryProviderStub.fetchCountries().first?.flagImage, flagImage)
        XCTAssertEqual(countryProviderStub.fetchCountries().first?.exchangeRate, exchangeRate)
        XCTAssertEqual(countryProviderStub.fetchCountries().first?.currencyCode, currencyCode)
    }
    
    func test_countryProvider_createCountry() {
        let createdCountry = countryProviderStub.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        
        XCTAssertNotNil(createdCountry)
        XCTAssertEqual(createdCountry?.name, countryName)
        XCTAssertEqual(createdCountry?.lastUpdated, lastUpdated)
        XCTAssertEqual(createdCountry?.flagImage, flagImage)
        XCTAssertEqual(createdCountry?.exchangeRate, exchangeRate)
        XCTAssertEqual(createdCountry?.currencyCode, currencyCode)
    }

}
