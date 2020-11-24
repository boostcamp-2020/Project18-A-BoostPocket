//
//  CountryViewModelTests.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest

class CountryViewModelTests: XCTestCase {
    
    var countryListViewModel: CountryListPresentable!
    var persistenceManager: PersistenceManagable!
    var countryProvider: CountryProvidable!
    
    override func setUpWithError() throws {
        persistenceManager = PersistenceManager()
        countryProvider = CountryProvider(persistenceManager: persistenceManager)
        countryListViewModel = CountryListViewModel(countryProvider: countryProvider)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_create_CountryItemViewModel() {
        let name = "test name"
        let flag = Data()
        let currencyCode = "test code"
        let countryItemViewModel = CountryItemViewModel(name: name, flag: flag, currencyCode: currencyCode)
        XCTAssertNotNil(countryItemViewModel)
        XCTAssertEqual(countryItemViewModel.name, name)
        XCTAssertEqual(countryItemViewModel.flag, flag)
        XCTAssertEqual(countryItemViewModel.currencyCode, currencyCode)
    }
    
    func test_countryListViewModel_needFetchItem() {
        if let country1 = countryProvider.createCountry(name: "1", lastUpdated: Date(), flagImage: Data(), exchangeRate: 0.0, currencyCode: "11"),
           let country2 = countryProvider.createCountry(name: "2", lastUpdated: Date(), flagImage: Data(), exchangeRate: 12.0, currencyCode: "22") {
            countryListViewModel.needFetchItems()
            print(countryListViewModel.countries.count)
            XCTAssertEqual(countryListViewModel.countries.count, 2)
        }
    }
}
