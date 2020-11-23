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
    
    func test_fetch_countries_empty() {
        // given: none
        
        // when
        let fetchedCountries = countryProviderStub.fetchCountries()
        
        // then
        XCTAssertEqual(fetchedCountries, [])
    }
}
