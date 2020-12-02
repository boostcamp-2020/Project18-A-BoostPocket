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
    var historyProvider: HistoryProvidable!

    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        
        historyProvider = HistoryProvider(persistenceManager: persistenceManagerStub)
    }

    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        historyProvider = nil
    }
    
    func test_historyProvider_craeteHistory() {
    
    }
    
    func test_historyProvider_fetchHistories() {
        
    }

}
