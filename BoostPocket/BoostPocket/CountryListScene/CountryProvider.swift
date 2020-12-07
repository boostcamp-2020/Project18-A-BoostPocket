//
//  CountryProvider.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol CountryProvidable: AnyObject {
    var countries: [Country] { get }
    func fetchCountries() -> [Country]
}

class CountryProvider: CountryProvidable {

    private weak var persistenceManager: PersistenceManagable?
    var countries: [Country] = []
    
    init(persistenceManager: PersistenceManagable) {
        self.persistenceManager = persistenceManager
    }
    
    func fetchCountries() -> [Country] {
        guard let persistenceManager = persistenceManager else { return [] }
        
        countries.removeAll()
        countries = persistenceManager.fetchAll(request: Country.fetchRequest())
        
        return countries
    }
    
}
