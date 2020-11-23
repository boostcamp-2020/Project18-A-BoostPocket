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
    var session: URLSession!
    
    override func setUpWithError() throws {
        session = URLSession.shared
        dataLoaderStub = DataLoaderStub(session: session)
    }

    override func tearDownWithError() throws {
        session = nil
        dataLoaderStub = nil
    }
    
    func test_dataLoader_session() {
        // then
        XCTAssertEqual(dataLoaderStub.session, session)
    }
    
    func test_get_request_withURL() {
        // given
        let url = "https://mockurl"
        
        // when
        dataLoaderStub.requestExchangeRate(url: url) { _ in }
        
        // then
        XCTAssert(dataLoaderStub.requestURL?.absoluteString == url)
    }
    
    func test_convert_to_URL() {
        // given
        let url = "https://mockurl"
        
        // when
        let isValidURL = dataLoaderStub.converToURL(url: url)
        
        // then
        XCTAssertEqual(isValidURL?.absoluteString, url)
    }
}
