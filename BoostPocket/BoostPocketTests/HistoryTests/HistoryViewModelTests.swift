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
    let travelExpectation = XCTestExpectation(description: "Successfully create travel")

    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        
        countryProvider = CountryProvider(persistenceManager: persistenceManagerStub)
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
        historyProvider = HistoryProvider(persistenceManager: persistenceManagerStub)
        
        travelListViewModel = TravelListViewModel(countryProvider: countryProvider, travelProvider: travelProvider, historyProvider: historyProvider)
        
        persistenceManagerStub.createCountriesWithAPIRequest { [weak self] result in
            if let self = self, result {
                self.countriesExpectation.fulfill()
                self.travelProvider.createTravel(countryName: self.countryName) { travel in
                    if let createdTravel = travel {
                        self.travelItemViewModel = TravelItemViewModel(travel: createdTravel, historyProvider: self.historyProvider)
                        self.travelExpectation.fulfill()
                    }
                }

            }
        }
        self.dataLoader = dataLoader
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        travelItemViewModel = nil
        countryProvider = nil
        travelProvider = nil
        historyProvider = nil
        dataLoader = nil
    }

    func test_travelItemViewModel_createHistory() {
        wait(for: [countriesExpectation, travelExpectation], timeout: 5.0)

        var createdHistoryItemViewModel: HistoryItemViewModel?
        travelItemViewModel.createHistory(id: UUID(), isIncome: false, title: "title", memo: "memo", date: Date(), image: Data(), amount: Double(), category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            createdHistoryItemViewModel = historyItemViewModel
        }
        XCTAssertNotNil(createdHistoryItemViewModel)
        XCTAssertEqual(createdHistoryItemViewModel?.title, "title")
    }

}
