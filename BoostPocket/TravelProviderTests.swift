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
    var travelProviderStub: TravelProvidable!

    override func setUpWithError() throws {
        persistenceManagerStub = PersistenceManagerStub()
        travelProviderStub = TravelProvider(persistenceManager: persistenceManagerStub)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        travelProviderStub = nil
    }

    func test_travelProvier_createTravel() {
        
        let countryName = "대한민국"
        let countryProviderStub = CountryProvider(persistenceManager: persistenceManagerStub)
        countryProviderStub.createCountry(name: countryName, lastUpdated: Date(), flagImage: Data(), exchangeRate: 1.0, currencyCode: "KRW")
        let createdTravel = travelProviderStub.createTravel(countryName: countryName)
        
        XCTAssertNotNil(createdTravel)
        XCTAssertEqual(createdTravel?.title, countryName)
        XCTAssertEqual(createdTravel?.country?.name, countryName)
    }

}
