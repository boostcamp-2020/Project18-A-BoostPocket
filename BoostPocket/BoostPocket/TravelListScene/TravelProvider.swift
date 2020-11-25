//
//  TravelProvider.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
import CoreData

protocol TravelProvidable: AnyObject {
    var travels: [Travel] { get }
    @discardableResult func createTravel(countryName: String) -> Travel?
    func fetchTravels() -> [Travel]
    func deleteTravel()
}

class TravelProvider: TravelProvidable {
    
    private weak var persistenceManager: PersistenceManagable?
    var travels: [Travel] = []
    
    init(persistenceManager: PersistenceManagable) {
        self.persistenceManager = persistenceManager
    }
    
    @discardableResult
    func createTravel(countryName: String) -> Travel? {
        let newTravelInfo = TravelInfo(countryName: countryName)
        
        guard let createdObject = persistenceManager?.createObject(newObjectInfo: newTravelInfo),
            let createdTravel = createdObject as? Travel
            else { return nil }
        
        return createdTravel
    }
    
    func fetchTravels() -> [Travel] {
        
        return []
    }
    
    func deleteTravel() {
        
    }
}
