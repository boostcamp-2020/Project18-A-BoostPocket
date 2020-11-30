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
    func createCountry(name: String, lastUpdated: Date, flagImage: Data, exchangeRate: Double, currencyCode: String) -> Country?
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
    
    func createCountry(name: String, lastUpdated: Date, flagImage: Data, exchangeRate: Double, currencyCode: String) -> Country? {
        let newCountryInfo = CountryInfo(name: name,
                                         lastUpdated: lastUpdated,
                                         flagImage: flagImage,
                                         exchangeRate: exchangeRate,
                                         currencyCode: currencyCode)
        
        guard let createdObject = persistenceManager?.createObject(newObjectInfo: newCountryInfo),
            let createdCountry = createdObject as? Country
            else { return nil }
        
        return createdCountry
    }
}
