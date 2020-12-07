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
        let history1 = HistoryStub(id: UUID(), isIncome: false, title: "All1", memo: "all1", amount: 11000, image: Data(), date: Date(), category: 0, isCard: nil, isPrepare: false)
        let history2 = HistoryStub(id: UUID(), isIncome: false, title: "All2", memo: "cash1", amount: 12000, image: Data(), date: Date(), category: 0, isCard: false, isPrepare: false)
        let history3 = HistoryStub(id: UUID(), isIncome: false, title: "All3", memo: "card1", amount: 13000, image: Data(), date: Date(), category: 0, isCard: true, isPrepare: false)
        let history4 = HistoryStub(id: UUID(), isIncome: false, title: "Prepare1", memo: "all2", amount: 14000, image: Data(), date: Date(), category: 0, isCard: nil, isPrepare: true)
        let history5 = HistoryStub(id: UUID(), isIncome: false, title: "Prepare2", memo: "cash2", amount: 15000, image: Data(), date: Date(), category: 0, isCard: false, isPrepare: true)
        let history6 = HistoryStub(id: UUID(), isIncome: false, title: "Prepare3", memo: "card2", amount: 16000, image: Data(), date: Date(), category: 0, isCard: true, isPrepare: true)
        let history7 = HistoryStub(id: UUID(), isIncome: false, title: "Date1", memo: "all3", amount: 17000, image: Data(), date: Date(), category: 0, isCard: nil, isPrepare: nil)
        let history8 = HistoryStub(id: UUID(), isIncome: false, title: "Date2", memo: "cash3", amount: 18000, image: Data(), date: Date(), category: 0, isCard: false, isPrepare: nil)
        let history9 = HistoryStub(id: UUID(), isIncome: false, title: "Date3", memo: "card3", amount: 19000, image: Data(), date: Date(), category: 0, isCard: true, isPrepare: nil)

        histories.append(HistoryItemViewModelStub(history: history1))
        histories.append(HistoryItemViewModelStub(history: history2))
        histories.append(HistoryItemViewModelStub(history: history3))
        histories.append(HistoryItemViewModelStub(history: history4))
        histories.append(HistoryItemViewModelStub(history: history5))
        histories.append(HistoryItemViewModelStub(history: history6))
        histories.append(HistoryItemViewModelStub(history: history7))
        histories.append(HistoryItemViewModelStub(history: history8))
        histories.append(HistoryItemViewModelStub(history: history9))
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
    
    func test_toggleIsPrepareOnly() {
        XCTAssertNotNil(historyFilter.isPrepareOnly)
        XCTAssertFalse(historyFilter.isPrepareOnly!)
        historyFilter.toggleIsPrepareOnly()
        XCTAssertNotNil(historyFilter.isPrepareOnly)
        XCTAssertTrue(historyFilter.isPrepareOnly!)
    }
    
    func test_toggleIsCardOnly() {
        historyFilter.isCardOnly = false
        historyFilter.toggleIsCardOnly()
        XCTAssertTrue(historyFilter.isCardOnly!)
    }
    
    func test_filterHistories() {
    }
}
