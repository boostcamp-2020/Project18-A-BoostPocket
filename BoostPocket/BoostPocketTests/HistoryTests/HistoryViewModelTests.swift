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
    
//    let id = UUID()
//    let title = "test title"
//    let memo = "memo"
//    let budget = 3.29
//    let coverImage = Data()
//    let startDate = Date()
//    let endDate = Date()
//    let exchangeRate = 12.1

//    let lastUpdated = "2019-08-23".convertToDate()
//    let flagImage = Data()
//    let currencyCode = "KRW"
    
    let countryName = "대한민국"
    let id = UUID()
    let isIncome = false
    let title = "테스트지출"
    let memo = "테스트메모"
    let date = "2020-12-21".convertToDate()
    let category = HistoryCategory.shopping
    let amount = Double()
    let image = Data()
    let isPrepare = true
    let isCard = true

    var persistenceManagerStub: PersistenceManagable!
    var travelItemViewModel: HistoryListPresentable!
    var travelListViewModel: TravelListPresentable!
    var createdTravel: Travel!
    
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
                    self.createdTravel = travel
                    XCTAssertNotNil(self.createdTravel)
                    self.travelItemViewModel = TravelItemViewModel(travel: self.createdTravel, historyProvider: self.historyProvider)
                    self.travelExpectation.fulfill()
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
        createdTravel = nil
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
    
    func test_travelItemViewModel_needFetchItems() {
        wait(for: [countriesExpectation, travelExpectation], timeout: 5.0)
        
        travelItemViewModel.needFetchItems()
        XCTAssertEqual(travelItemViewModel.histories, [])
        
        let historyInfo = HistoryInfo(travelId: (createdTravel?.id)!, id: id, isIncome: isIncome, title: title, memo: memo, date: date, category: category, amount: amount, image: image, isPrepare: isPrepare, isCard: isCard)
        
        var createdHistory: History?
        historyProvider.createHistory(createdHistoryInfo: historyInfo) { history in
            createdHistory = history
        }
        XCTAssertNotNil(createdHistory)

        travelItemViewModel.needFetchItems()
        XCTAssertNotEqual(travelItemViewModel.histories, [])
    }
    
    func test_travelItemViewModel_updateHistory() {
        wait(for: [countriesExpectation, travelExpectation], timeout: 5.0)
        
        var createdHistoryItemViewModel: HistoryItemViewModel?
        travelItemViewModel.createHistory(id: id, isIncome: isIncome, title: title, memo: memo, date: date, image: image, amount: amount, category: category, isPrepare: isPrepare, isCard: isCard) { historyItemViewModel in
            createdHistoryItemViewModel = historyItemViewModel
        }
        XCTAssertNotNil(createdHistoryItemViewModel)
        
        XCTAssertTrue(travelItemViewModel.updateHistory(id: createdHistoryItemViewModel?.id ?? UUID(), isIncome: createdHistoryItemViewModel!.isIncome, title: "변경한 타이틀", memo: "변경한 메모", date: nil, image: Data(), amount: 10.0, category: HistoryCategory.food, isPrepare: false, isCard: false))
        
        let updatedHistoryItemViewModel = travelItemViewModel.histories.first
        XCTAssertNotNil(updatedHistoryItemViewModel)
        XCTAssertEqual(updatedHistoryItemViewModel?.title, "변경한 타이틀")
        XCTAssertEqual(createdHistoryItemViewModel, updatedHistoryItemViewModel)
        
    }

}
