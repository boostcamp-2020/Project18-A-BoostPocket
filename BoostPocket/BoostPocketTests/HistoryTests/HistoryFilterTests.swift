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

    func testExample() throws {
    }
}
