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
    
    var countryListViewModel: CountryListPresentable!
    var persistenceManagerStub: PersistenceManagable!
    var countryProvider: CountryProvidable!
    
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
        countryProvider = CountryProvider(persistenceManager: persistenceManagerStub)
        countryListViewModel = CountryListViewModel(countryProvider: countryProvider)
    }
    
    override func tearDownWithError() throws {
        countryListViewModel = nil
        countryProvider = nil
        persistenceManagerStub = nil
    }
    
    func test_countryItemViewModel_createInstance() {
        let country = CountryStub(name: countryName, flagImage: flagImage, currencyCode: currencyCode)
        let countryItemViewModel = CountryItemViewModel(country: country)
        
        XCTAssertNotNil(countryItemViewModel)
        XCTAssertEqual(countryItemViewModel.name, countryName)
        XCTAssertEqual(countryItemViewModel.flag, flagImage)
        XCTAssertEqual(countryItemViewModel.currencyCode, currencyCode)
    }
    
    func test_countryListViewModel_numberOfItem() {
        let expectation = XCTestExpectation(description: "Successfully Created Country")
        
        persistenceManagerStub.createObject(newObjectInfo: CountryInfo(name: countryName+"테스트", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier)) { dataModelProtocol in
            XCTAssertNotNil(dataModelProtocol)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        countryListViewModel.needFetchItems()
        XCTAssertEqual(countryListViewModel.numberOfItem(), 1)
        XCTAssertEqual(countryListViewModel.countries.first?.name, "\(countryName)테스트")
    }
    
    func test_countryListViewModel_needFetchItem() {
        let expectation = XCTestExpectation(description: "Successfully Created Country")
        
        persistenceManagerStub.createObject(newObjectInfo: CountryInfo(name: countryName+"가", lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier)) { dataModelProtocol in
            XCTAssertNotNil(dataModelProtocol)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        countryListViewModel.needFetchItems()
        XCTAssertEqual(countryListViewModel.countries.count, 1)
        XCTAssertEqual(countryListViewModel.countries.first?.name, "\(countryName)가")
    }
}
