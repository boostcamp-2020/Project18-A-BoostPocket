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
    
    override func setUpWithError() throws {
        historyFilter = HistoryFilter()
    }

    override func tearDownWithError() throws {
        historyFilter = nil
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
}
