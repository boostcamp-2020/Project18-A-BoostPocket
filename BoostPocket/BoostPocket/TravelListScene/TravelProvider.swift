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
        
        guard let persistenceManager = persistenceManager,
              let entity = NSEntityDescription.entity(forEntityName: "Travel", in: persistenceManager.context)
        else { return nil }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        fetchRequest.predicate = NSPredicate(format: "name == %@", countryName)
        
        guard let countries = persistenceManager.fetch(fetchRequest) as? [Country],
              let fetchedCountry = countries.first else { return nil }
        
        let newTravel = Travel(entity: entity, insertInto: persistenceManager.context)
        newTravel.title = countryName
        newTravel.exchangeRate = fetchedCountry.exchangeRate
        newTravel.country = fetchedCountry
        
        let urlString: String = "https://source.unsplash.com/random/500x500"
        guard let url = URL(string: urlString) else { return nil }
        let data = try? Data(contentsOf: url)
        // TODO : asset 에 default 이미지 추가
        newTravel.coverImage = data
        
        return newTravel
    }
    
    func fetchTravels() -> [Travel] {
        
        return []
    }
    
    func deleteTravel() {
        
    }
}
