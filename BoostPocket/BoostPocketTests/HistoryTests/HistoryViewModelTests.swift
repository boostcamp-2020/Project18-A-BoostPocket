//
//  HistoryViewModelTests.swift
//  BoostPocketTests
//
//  Created by 이승진 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import NetworkManager
@testable import BoostPocket

class HistoryViewModelTests: XCTestCase {
    
    let id = UUID()
    let title = "test title"
    let memo = "memo"
    let budget = 3.29
    let coverImage = Data()
    let startDate = Date()
    let endDate = Date()
    let exchangeRate = 12.1
    let countryName = "대한민국"
    let lastUpdated = "2019-08-23".convertToDate()
    let flagImage = Data()
    let currencyCode = "KRW"

    var persistenceManagerStub: PersistenceManagable!
    var travelItemViewModel: HistoryListPresentable!
    var travelListViewModel: TravelListPresentable!
    var dataLoader: DataLoader?
    var countryProvider: CountryProvidable!
    var travelProvider: TravelProvidable!
    var historyProvider: HistoryProvidable!
    let countriesExpectation = XCTestExpectation(description: "Successfully Created Countries")

    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        
        countryProvider = CountryProvider(persistenceManager: persistenceManagerStub)
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
        historyProvider = HistoryProvider(persistenceManager: persistenceManagerStub)
        
        travelListViewModel = TravelListViewModel(countryProvider: countryProvider, travelProvider: travelProvider)
        
        persistenceManagerStub.createCountriesWithAPIRequest { [weak self] (result) in
            if result {
//                let fetchedCountries = self.countryProvider.fetchCountries()
//                let firstCountry = fetchedCountries.first
//                XCTAssertNotNil(fetchedCountries)
//                XCTAssertNotNil(firstCountry)
                
//                let travel = TravelStub(id: self.id, title: self.title, memo: self.memo, exchangeRate: self.exchangeRate,
//                                        budget: self.budget, coverImage: self.coverImage, startDate: self.startDate,
//                                        endDate: self.endDate, country: firstCountry)
//
//                self.travelItemViewModel = TravelItemViewModel(travel: travel)
                self?.countriesExpectation.fulfill()
            }
        }
        self.dataLoader = dataLoader
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        travelItemViewModel = nil
        countryProvider = nil
        travelProvider = nil
        dataLoader = nil
    }

    func test_travelItemViewModel_createHistory() {
        wait(for: [countriesExpectation], timeout: 5.0)
        let travelExpectation = XCTestExpectation(description: "Successfully create travel")
        
        travelListViewModel.createTravel(countryName: countryName) { [weak self] travelItemViewModel in
            self?.travelItemViewModel = travelItemViewModel
            XCTAssertNotNil(self?.travelItemViewModel)
            travelExpectation.fulfill()
        }
        
        wait(for: [travelExpectation], timeout: 5.0)
        travelItemViewModel.historyProvider = historyProvider
        var createdHistoryItemViewModel: HistoryItemViewModel?
        travelItemViewModel.createHistory(id: UUID(), isIncome: false, title: "title", memo: "memo", date: Date(), image: Data(), amount: Double(), category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            createdHistoryItemViewModel = historyItemViewModel
        }
        XCTAssertNotNil(createdHistoryItemViewModel)
        XCTAssertEqual(createdHistoryItemViewModel?.title, "title")
    }

}
