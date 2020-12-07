//
//  HistoryFilterTests.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class HistoryFilterTests: XCTestCase {

    private var historyFilter: HistoryFilter!
    private var histories: [HistoryItemViewModelStub] = []
    
    override func setUpWithError() throws {
        historyFilter = HistoryFilter()
        let historyStubs = [
            HistoryStub(id: UUID(), isIncome: false, title: "All1", memo: "All1", amount: 11000, image: Data(), date: Date(), category: 0, isCard: true, isPrepare: false),
            HistoryStub(id: UUID(), isIncome: false, title: "All2", memo: "Cash1", amount: 12000, image: Data(), date: Date(), category: 0, isCard: false, isPrepare: false),
            HistoryStub(id: UUID(), isIncome: false, title: "All3", memo: "Card1", amount: 13000, image: Data(), date: Date(), category: 0, isCard: true, isPrepare: false),
            HistoryStub(id: UUID(), isIncome: false, title: "Prepare1", memo: "All2", amount: 14000, image: Data(), date: Date(), category: 0, isCard: false, isPrepare: true),
            HistoryStub(id: UUID(), isIncome: false, title: "Prepare2", memo: "Cash2", amount: 15000, image: Data(), date: Date(), category: 0, isCard: false, isPrepare: true),
            HistoryStub(id: UUID(), isIncome: false, title: "Prepare3", memo: "Card2", amount: 16000, image: Data(), date: Date(), category: 0, isCard: true, isPrepare: true),
            HistoryStub(id: UUID(), isIncome: false, title: "Date1", memo: "All3", amount: 17000, image: Data(), date: Date(), category: 0, isCard: false, isPrepare: true),
            HistoryStub(id: UUID(), isIncome: false, title: "Date2", memo: "Cash3", amount: 18000, image: Data(), date: Date(), category: 0, isCard: false, isPrepare: false),
            HistoryStub(id: UUID(), isIncome: false, title: "Date3", memo: "Card3", amount: 19000, image: Data(), date: Date(), category: 0, isCard: true, isPrepare: false)
        ]
        
        historyStubs.forEach { stub in
            histories.append(HistoryItemViewModelStub(history: stub))
        }
    }

    override func tearDownWithError() throws {
        historyFilter = nil
        histories = []
    }

    func test_init_HistoryFilter() throws {
        historyFilter = nil
        XCTAssertNil(historyFilter)
        historyFilter = HistoryFilter()
        XCTAssertNotNil(historyFilter)
        XCTAssertNotNil(historyFilter.isPrepareOnly)
        XCTAssertFalse(historyFilter.isPrepareOnly!)
        XCTAssertNil(historyFilter.isCardOnly)
        XCTAssertNil(historyFilter.selectedDate)
    }
    
    func test_filterHistories_All_All() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = false
        historyFilter.selectedDate = nil
        historyFilter.isCardOnly = nil
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 9)
    }
    
    func test_filterHistories_All_Card() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = false
        historyFilter.selectedDate = nil
        historyFilter.isCardOnly = true
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 4)
    }
    
    func test_filterHistories_All_Cash() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = false
        historyFilter.selectedDate = nil
        historyFilter.isCardOnly = false
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 5)
    }
    
    func test_filterHistories_Prepared_All() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = true
        historyFilter.selectedDate = nil
        historyFilter.isCardOnly = nil
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 4)
    }
    
    func test_filterHistories_Prepared_Card() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = true
        historyFilter.selectedDate = nil
        historyFilter.isCardOnly = true
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 1)
    }
    
    func test_filterHistories_Prepared_Cash() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = true
        historyFilter.selectedDate = nil
        historyFilter.isCardOnly = false
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 3)
    }
    
    func test_filterHistories_Date_All() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = nil
        historyFilter.selectedDate = Date()
        historyFilter.isCardOnly = nil
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 9)
    }
    
    func test_filterHistories_Date_Card() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = nil
        historyFilter.selectedDate = Date()
        historyFilter.isCardOnly = true
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 4)
    }
    
    func test_filterHistories_Date_Cash() {
        let castedHistories = histories as [HistoryItemViewModel]
        historyFilter.isPrepareOnly = nil
        historyFilter.selectedDate = Date()
        historyFilter.isCardOnly = false
        let filteredHistories = historyFilter.filterHistories(with: castedHistories)
        XCTAssertNotNil(filteredHistories)
        XCTAssertEqual(filteredHistories.count, 5)
    }
}
