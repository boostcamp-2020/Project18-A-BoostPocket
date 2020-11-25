//
//  TravelProvider.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol TravelProvidable: AnyObject {
    var travels: [Travel] { get }
    func createTravel() -> Travel?
    func fetchTravels() -> [Travel]
    func deleteTravel()
}

class TravelProvider: TravelProvidable {
    
    private weak var persistenceManager: PersistenceManagable?
    var travels: [Travel] = []
    
    init(persistenceManager: PersistenceManagable) {
        self.persistenceManager = persistenceManager
    }
    
    func createTravel() -> Travel? {
        
        return nil
    }
    
    func fetchTravels() -> [Travel] {
        
        return []
    }
    
    func deleteTravel() {
        
    }
}
