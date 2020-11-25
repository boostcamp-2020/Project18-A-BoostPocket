//
//  TravelProviderTests.swift
//  BoostPocketTests
//
//  Created by 이승진 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class TravelProviderTests: XCTestCase {
    
    var persistenceManagerStub: PersistenceManagable!
    var travelProviderStub: TravelProvidable!

    override func setUpWithError() throws {
        persistenceManagerStub = PersistenceManagerStub()
        travelProviderStub = TravelProvider(persistenceManager: persistenceManagerStub)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        travelProviderStub = nil
    }

    func test_travelProvier_createTravel() {
        
    }

}
