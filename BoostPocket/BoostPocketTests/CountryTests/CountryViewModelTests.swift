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
    let flagImage = Data()
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
    
    func test_countryItemViewModel_createInstance() {
        let country = CountryStub(name: countryName, flagImage: flagImage, currencyCode: currencyCode)
        let countryItemViewModel = CountryItemViewModel(country: country)
        
        XCTAssertNotNil(countryItemViewModel)
        XCTAssertEqual(countryItemViewModel.name, countryName)
        XCTAssertEqual(countryItemViewModel.flag, flagImage)
        XCTAssertEqual(countryItemViewModel.currencyCode, currencyCode)
    }
    
    func test_countryListViewModel_createCountry() {
        let country = countryListViewModel.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        
        XCTAssertNotNil(country)
        XCTAssertEqual(country, countryListViewModel.countries.first)
        
        if let createdCountry = country {
            XCTAssertEqual(createdCountry.name, countryName)
            XCTAssertEqual(createdCountry.flag, flagImage)
            XCTAssertEqual(createdCountry.currencyCode, currencyCode)
        }
    }
    
    func test_countryListViewModel_cellForItemAt() {
        countryListViewModel.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
        
        let countryItemViewModel = countryListViewModel.cellForItemAt(path: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(countryItemViewModel, countryListViewModel.countries.first)
        XCTAssertEqual(countryItemViewModel.name, countryName)
        XCTAssertEqual(countryItemViewModel.flag, flagImage)
        XCTAssertEqual(countryItemViewModel.currencyCode, currencyCode)
    }
    
    func test_countryListViewModel_numberOfItem() {
        countryListViewModel.createCountry(name: "\(countryName)1", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 0.0, currencyCode: "\(currencyCode)1")
        countryListViewModel.createCountry(name: "\(countryName)2", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 1.0, currencyCode: "\(currencyCode)2")
        countryListViewModel.createCountry(name: "\(countryName)3", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 2.0, currencyCode: "\(currencyCode)3")
        
        XCTAssertEqual(countryListViewModel.numberOfItem(), 3)
    }
    
    func test_countryListViewModel_needFetchItem() {
        XCTAssertNotNil(countryProvider.createCountry(name: "\(countryName)다", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 0.0, currencyCode: "\(currencyCode)2"))
        XCTAssertNotNil(countryProvider.createCountry(name: "\(countryName)나", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 0.0, currencyCode: "\(currencyCode)1"))
        XCTAssertNotNil(countryProvider.createCountry(name: "\(countryName)라", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 0.0, currencyCode: "\(currencyCode)2"))
        XCTAssertNotNil(countryProvider.createCountry(name: "\(countryName)가", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 0.0, currencyCode: "\(currencyCode)2"))
        
        countryListViewModel.needFetchItems()
        XCTAssertEqual(countryListViewModel.countries.count, 4)
        XCTAssertEqual(countryListViewModel.countries.first?.name, "\(countryName)가")
        XCTAssertEqual(countryListViewModel.countries.last?.name, "\(countryName)라")
    }
}
