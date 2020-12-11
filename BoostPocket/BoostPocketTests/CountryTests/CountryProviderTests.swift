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
    let lastUpdated = "2019-08-23".convertToDate()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    let identifier = "ko_KR"
    
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
        let expectation = XCTestExpectation(description: "Successfully Created Country")
        
        XCTAssertEqual(countryProviderStub.fetchCountries(), [])
        
        persistenceManagerStub.createObject(newObjectInfo: CountryInfo(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier)) { dataModelProtocol in
            XCTAssertNotNil(dataModelProtocol)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotEqual(countryProviderStub.fetchCountries(), [])
        XCTAssertEqual(countryProviderStub.countries.count, 1)
    }

}
