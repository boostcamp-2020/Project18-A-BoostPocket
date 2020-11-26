//
//  TravelViewModelTests.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class TravelViewModelTests: XCTestCase {
    
    var travelListViewModel: TravelListPresentable!
    var persistenceManager: PersistenceManagable!
    var countryProvider: CountryProvidable!
    var travelProvider: TravelProvidable!
    
    var id = UUID()
    var title = "test title"
    var memo = "memo"
    var exchangeRate = 12.1
    var budget = 3.29
    var coverImage = Data()
    var startDate = Date()
    var endDate = Date()

    override func setUpWithError() throws {
        persistenceManager = PersistenceManagerStub()
        countryProvider = CountryProvider(persistenceManager: persistenceManager)
        travelProvider = TravelProvider(persistenceManager: persistenceManager)
        travelListViewModel = TravelListViewModel(countryProvider: countryProvider, travelProvider: travelProvider)
    }

    override func tearDownWithError() throws {
        travelListViewModel = nil
        travelProvider = nil
        countryProvider = nil
        persistenceManager = nil
    }

    func test_TravelItemViewModel_createInstance() throws {
        let country = countryProvider.createCountry(name: "test name", lastUpdated: Date(), flagImage: Data(), exchangeRate: 3.29, currencyCode: "KRW")
        let travel = TravelStub(id: id, title: title, memo: memo, exchangeRate: exchangeRate,
                                budget: budget, coverImage: coverImage, startDate: startDate,
                                endDate: endDate, country: country)
        let travelItemViewModel = TravelItemViewModel(travel: travel)
        
        XCTAssertNotNil(travel)
        XCTAssertEqual(travelItemViewModel.id, id)
        XCTAssertEqual(travelItemViewModel.title, title)
        XCTAssertEqual(travelItemViewModel.memo, memo)
        XCTAssertEqual(travelItemViewModel.exchangeRate, exchangeRate)
        XCTAssertEqual(travelItemViewModel.budget, budget)
        XCTAssertEqual(travelItemViewModel.coverImage, coverImage)
        XCTAssertEqual(travelItemViewModel.startDate, startDate)
        XCTAssertEqual(travelItemViewModel.endDate, endDate)
        XCTAssertEqual(travelItemViewModel.currencyCode, country?.currencyCode)
        XCTAssertEqual(travelItemViewModel.flagImage, country?.flagImage)
        XCTAssertEqual(travelItemViewModel.countryName, country?.name)
    }
    
    func test_TravelListViewModel_createTravel() {
        let countryName = "대한민국"
        let travel = travelListViewModel.createTravel(countryName: countryName)
        
        XCTAssertNotNil(travel)
        XCTAssertEqual(travel, travelListViewModel.travels.first)
        
        if let createdTravel = travel {
            XCTAssertEqual(createdTravel.title, countryName)
            XCTAssertEqual(createdTravel.countryName, countryName)
        }
    }
}
