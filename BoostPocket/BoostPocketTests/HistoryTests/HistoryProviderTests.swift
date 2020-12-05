//
//  HistoryProviderTests.swift
//  BoostPocketTests
//
//  Created by 이승진 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import NetworkManager
@testable import BoostPocket

class HistoryProviderTests: XCTestCase {
    
    var persistenceManagerStub: PersistenceManagable!
    var travelProvider: TravelProvidable!
    var historyProvider: HistoryProvidable!
    var dataLoader: DataLoader!
    var createdTravel: Travel!
    var historyInfo: HistoryInfo!
    
    let countryName = "대한민국"
    let countriesExpectation = XCTestExpectation(description: "Successfully created country")
    let travelExpectation = XCTestExpectation(description: "Successfully create travel")
    
    let id = UUID()
    let isIncome = false
    let title = "기록테스트"
    let memo = "메모테스트"
    let date = Date()
    let category = HistoryCategory.food
    let amount = Double()
    let image = Data()
    let isPrepare = false
    let isCard = false

    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        
        persistenceManagerStub.createCountriesWithAPIRequest { [weak self] result in
            if let self = self, result {
                self.countriesExpectation.fulfill()
                self.travelProvider.createTravel(countryName: self.countryName) { travel in
                    self.createdTravel = travel
                    XCTAssertNotNil(self.createdTravel)
                    self.historyInfo = HistoryInfo(travelId: self.createdTravel.id!, id: self.id, isIncome: self.isIncome, title: self.title, memo: self.memo, date: self.date, category: self.category, amount: self.amount, image: self.image, isPrepare: self.isPrepare, isCard: self.isCard)
                    self.travelExpectation.fulfill()
                }
            }
        }
        
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
        historyProvider = HistoryProvider(persistenceManager: persistenceManagerStub)
        
        self.dataLoader = dataLoader
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        travelProvider = nil
        historyProvider = nil
        dataLoader = nil
        createdTravel = nil
    }
    
    func test_historyProvider_createHistory() {
        wait(for: [countriesExpectation, travelExpectation], timeout: 5.0)

        var createdHistory: History?
        historyProvider.createHistory(createdHistoryInfo: historyInfo) { history in
            createdHistory = history
        }
        
        XCTAssertNotNil(createdHistory)
        XCTAssertEqual(createdHistory?.travel, createdTravel)
    }
    
    func test_historyProvider_fetchHistories() {
        wait(for: [countriesExpectation, travelExpectation], timeout: 5.0)
        
        let fetchedHistories = historyProvider.fetchHistories()
        XCTAssertEqual(fetchedHistories, [])
        
        var createdHistory: History?
        historyProvider.createHistory(createdHistoryInfo: historyInfo) { (history) in
            createdHistory = history
        }
        XCTAssertNotNil(createdHistory)
        
        let firstHistory = historyProvider.fetchHistories().first
        XCTAssertNotNil(firstHistory)
        XCTAssertEqual(firstHistory, createdHistory)
    }
    
    func test_historyProvider_deleteHistory() {
        wait(for: [countriesExpectation, travelExpectation], timeout: 5.0)
        
        var createdHistory: History?
        historyProvider.createHistory(createdHistoryInfo: historyInfo) { (history) in
            createdHistory = history
        }
        XCTAssertNotNil(createdHistory)
        
        XCTAssertTrue(historyProvider.deleteHistory(id: createdHistory?.id ?? UUID()))
        XCTAssertEqual(historyProvider.fetchHistories(), [])
    }
    
    func test_historyProvider_updateHistory() {
        wait(for: [countriesExpectation, travelExpectation], timeout: 5.0)
        
        var createdHistory: History?
        historyProvider.createHistory(createdHistoryInfo: historyInfo) { (history) in
            createdHistory = history
        }
        XCTAssertNotNil(createdHistory)
        
        let updatingHistoryInfo = HistoryInfo(travelId: historyInfo.travelId, id: historyInfo.id, isIncome: true, title: "변경한 제목", memo: nil, date: "2019-11-30-12-01-00".convertToDate(), category: .income, amount: 13.4, image: nil, isPrepare: false, isCard: true)
        
        let updatedHistory = historyProvider.updateHistory(updatedHistoryInfo: updatingHistoryInfo)
        
        XCTAssertNotNil(updatedHistory)
        XCTAssertEqual(updatedHistory, createdHistory)
        XCTAssertEqual(updatedHistory?.travel?.id, historyInfo.travelId)
        XCTAssertEqual(updatedHistory?.id, historyInfo.id)
        XCTAssertEqual(updatedHistory?.title, "변경한 제목")
        XCTAssertEqual(updatedHistory?.categoryState, HistoryCategory.income)
    }

}
