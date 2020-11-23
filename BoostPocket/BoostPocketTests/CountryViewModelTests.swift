//
//  CountryViewModelTests.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest

class CountryViewModelTests: XCTestCase {
    
    var countryItemViewModel: CountryItemViewModelProtocol!
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_create_CountryItemViewModel() {
        let name = "test name"
        let flag = Data()
        let currencyCode = "test code"
        countryItemViewModel = CountryItemViewModel(name: name, flag: flag, currencyCode: currencyCode)
        XCTAssertNotNil(countryItemViewModel)
        XCTAssertEqual(countryItemViewModel.name, name)
        XCTAssertEqual(countryItemViewModel.flag, flag)
        XCTAssertEqual(countryItemViewModel.currencyCode, currencyCode)
    }

}
