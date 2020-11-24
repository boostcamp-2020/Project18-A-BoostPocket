//
//  CountryViewModelTests.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class CountryViewModelTests: XCTestCase {
    
    var countryListViewModel: CountryListPresentable!
    var persistenceManager: PersistenceManagable!
    var countryProvider: CountryProvidable!
    
    override func setUpWithError() throws {
        persistenceManager = PersistenceManagerStub()
        countryProvider = CountryProvider(persistenceManager: persistenceManager)
        countryListViewModel = CountryListViewModel(countryProvider: countryProvider)
    }

    override func tearDownWithError() throws {
        countryListViewModel = nil
        countryProvider = nil
        persistenceManager = nil
    }
    
    func test_create_CountryItemViewModel() {
        let name = "test name"
        let flag = Data()
        let currencyCode = "test code"
        let country = CountryStub(name: name, flagImage: flag, currencyCode: currencyCode)
        let countryItemViewModel = CountryItemViewModel(country: country)
        XCTAssertNotNil(countryItemViewModel)
        XCTAssertEqual(countryItemViewModel.name, name)
        XCTAssertEqual(countryItemViewModel.flag, flag)
        XCTAssertEqual(countryItemViewModel.currencyCode, currencyCode)
    }
    
//    func test_countryListViewModel_cellForItemAt() {
//        if let country1 = countryProvider.createCountry(name: "test name", lastUpdated: Date(), flagImage: Data(), exchangeRate: 0.0, currencyCode: "KRW"),
//           let item = countryListViewModel.cellForItemAt(path: IndexPath(row: 0, section: 0)) as? Country {
//            XCTAssertEqual(country1, item)
//        }
//
//    }
    
    func test_countryListViewModel_needFetchItem() {
        if let country1 = countryProvider.createCountry(name: "test1", lastUpdated: Date(), flagImage: Data(), exchangeRate: 0.0, currencyCode: "11"),
           let country2 = countryProvider.createCountry(name: "test2", lastUpdated: Date(), flagImage: Data(), exchangeRate: 12.0, currencyCode: "22")
        {
            countryListViewModel.needFetchItems()
            XCTAssertEqual(countryListViewModel.countries.count, 2)
        }
    }
}

class CountryStub: CountryProtocol {
    var name: String?
    var flagImage: Data?
    var currencyCode: String?
    
    init(name: String?, flagImage: Data?, currencyCode: String?) {
        self.name = name
        self.flagImage = flagImage
        self.currencyCode = currencyCode
    }
}
