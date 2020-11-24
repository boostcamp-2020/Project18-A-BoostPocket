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
    
    let countryName = "test name"
    let lastUpdated = Date()
    let flag = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    
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
        let country = CountryStub(name: countryName, flagImage: flag, currencyCode: currencyCode)
        let countryItemViewModel = CountryItemViewModel(country: country)
        XCTAssertNotNil(countryItemViewModel)
        XCTAssertEqual(countryItemViewModel.name, countryName)
        XCTAssertEqual(countryItemViewModel.flag, flag)
        XCTAssertEqual(countryItemViewModel.currencyCode, currencyCode)
    }
    
    func test_countryListViewModel_createCountry() {
        let country = countryListViewModel.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flag, exchangeRate: exchangeRate, currencyCode: currencyCode)
        XCTAssertNotNil(country)
        XCTAssertEqual(country, countryListViewModel.countries.first)
        if let createdCountry = country {
            XCTAssertEqual(createdCountry.name, countryName)
            XCTAssertEqual(createdCountry.name, countryName)
        }
    }
    
    func test_countryListViewModel_cellForItemAt() {
        countryListViewModel.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flag, exchangeRate: exchangeRate, currencyCode: currencyCode)
        let item = countryListViewModel.cellForItemAt(path: IndexPath(row: 0, section: 0))
        XCTAssertEqual(item, countryListViewModel.countries.first)
    }
    
    func test_countryListViewModel_numberOfItem() {
        countryListViewModel.createCountry(name: "test1", lastUpdated: lastUpdated, flagImage: flag, exchangeRate: 0.0, currencyCode: "11")
        countryListViewModel.createCountry(name: "test2", lastUpdated: lastUpdated, flagImage: flag, exchangeRate: 12.0, currencyCode: "22")
        countryListViewModel.createCountry(name: "test3", lastUpdated: lastUpdated, flagImage: flag, exchangeRate: 13.0, currencyCode: "33")
        countryListViewModel.createCountry(name: "test4", lastUpdated: lastUpdated, flagImage: flag, exchangeRate: 14.0, currencyCode: "44")
        countryListViewModel.createCountry(name: "test5", lastUpdated: lastUpdated, flagImage: flag, exchangeRate: 15.0, currencyCode: "55")
        
        XCTAssertEqual(countryListViewModel.numberOfItem(), 5)
    }
    
    func test_countryListViewModel_needFetchItem() {
        countryProvider.createCountry(name: "test1", lastUpdated: lastUpdated, flagImage: flag, exchangeRate: 0.0, currencyCode: "11")
        countryProvider.createCountry(name: "test2", lastUpdated: lastUpdated, flagImage: flag, exchangeRate: 12.0, currencyCode: "22")
        countryListViewModel.needFetchItems()
        
        XCTAssertEqual(countryListViewModel.countries.count, 2)
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
