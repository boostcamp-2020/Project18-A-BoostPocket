//
//  NetworkManagerTests.swift
//  NetworkManagerTests
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import NetworkManager

class NetworkManagerTests: XCTestCase {
    
    var dataLoaderStub: DataLoadable!
    
    override func setUpWithError() throws {
        dataLoaderStub = DataLoaderStub()
    }

    override func tearDownWithError() throws {
        dataLoaderStub = nil
    }
    
    func test_get_request_withURL() {
        let url = "https://mockurl"
        dataLoaderStub.requestExchangeRate(url: url) { _ in }
        
        XCTAssert(dataLoaderStub.requestURL?.absoluteString == url)
        
    }
    
    func test_convert_to_URL() {
        let url = "https://mockurl"
        XCTAssertEqual(dataLoaderStub.converToURL(url: url)?.absoluteString, url)
    }
}
