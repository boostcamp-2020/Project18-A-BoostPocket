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
    
    let countryName = "대한민국"
    
    let countriesExpectation = XCTestExpectation(description: "Successfully created country")

    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        persistenceManagerStub.createCountriesWithAPIRequest { [weak self] result in
            if result {
                self?.countriesExpectation.fulfill()
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
    }
    
    func test_historyProvider_createHistory() {
        wait(for: [countriesExpectation], timeout: 5.0)
        let travelExpectation = XCTestExpectation(description: "Successfully create travel")
        var createdTravel: Travel?
        travelProvider.createTravel(countryName: countryName) { travel in
            createdTravel = travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [travelExpectation], timeout: 5.0)
        
        let historyInfo = HistoryInfo(travelId: (createdTravel?.id)!, id: UUID(), isIncome: false, title: "식비", memo: nil, date: Date(), category: .food, amount: Double(), image: nil, isPrepare: nil, isCard: nil)
        var createdHistory: History?
        historyProvider.createHistory(createdHistoryInfo: historyInfo) { history in
            createdHistory = history
        }
        XCTAssertNotNil(createdHistory)
        XCTAssertEqual(createdHistory?.travel, createdTravel)
    }
    
    func test_historyProvider_fetchHistories() {
        
    }

}
