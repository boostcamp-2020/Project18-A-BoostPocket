//
//  CountryViewModelTests.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import NetworkManager
@testable import BoostPocket

class CountryViewModelTests: XCTestCase {
    
    var countryListViewModel: CountryListViewModelStub!
    var persistenceManager: PersistenceManagable!
    var countryProvider: CountryProviderStub!
    
    let countryName = "test name"
    let lastUpdated = "2019-08-23-12-01-33".convertToDate()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    let identifier = "ko_KR"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManager = PersistenceManagerStub(dataLoader: dataLoader)
        countryProvider = CountryProviderStub(persistenceManager: persistenceManager)
        countryListViewModel = CountryListViewModelStub(countryProvider: countryProvider)
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
        countryListViewModel.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier)
        
        let createdCountry = countryListViewModel.countries.first
        XCTAssertNotNil(createdCountry)
        XCTAssertEqual(createdCountry?.name, countryName)
        XCTAssertEqual(createdCountry?.flag, flagImage)
        XCTAssertEqual(createdCountry?.currencyCode, currencyCode)
    }
    
    func test_countryListViewModel_numberOfItem() {
        countryListViewModel.createCountry(name: "\(countryName)1", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 0.0, currencyCode: "\(currencyCode)1", identifier: identifier)
        countryListViewModel.createCountry(name: "\(countryName)2", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 1.0, currencyCode: "\(currencyCode)2", identifier: identifier)
        countryListViewModel.createCountry(name: "\(countryName)3", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 2.0, currencyCode: "\(currencyCode)3", identifier: identifier)
        
        XCTAssertEqual(countryListViewModel.numberOfItem(), 3)
    }
    
    func test_countryListViewModel_needFetchItem() {
        let expectation = XCTestExpectation(description: "Successfully Created Country")
        
        countryProvider.createCountry(name: "\(countryName)가", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: 0.0, currencyCode: "\(currencyCode)1", identifier: identifier) { (country) in
            XCTAssertNotNil(country)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        countryListViewModel.needFetchItems()
        XCTAssertEqual(countryListViewModel.countries.count, 1)
        XCTAssertEqual(countryListViewModel.countries.first?.name, "\(countryName)가")
    }
}
