//
//  NetworkManagerTests.swift
//  NetworkManagerTests
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest

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
    
    func test_dataLoader_requestExchangeRate() {
        // given
        let validURL = "https://mockurl"
        
        // when
        dataLoaderStub.requestExchangeRate(url: validURL) { _ in }
        
        // then
        XCTAssertNotNil(dataLoaderStub.requestURL)
        XCTAssert(dataLoaderStub.requestURL?.absoluteString == validURL)
    }
    
    func test_dataLoader_convertToURL() {
        // given
        let validURL = "https://mockurl"
        let invalidURL = "👍"
        
        // when
        let convertedValidURL = dataLoaderStub.convertToURL(url: validURL)
        let convertedInvalidURL = dataLoaderStub.convertToURL(url: invalidURL)
        
        // then
        XCTAssertNotNil(convertedValidURL)
        XCTAssertEqual(convertedValidURL?.absoluteString, validURL)
        XCTAssertNil(convertedInvalidURL)
    }
}
