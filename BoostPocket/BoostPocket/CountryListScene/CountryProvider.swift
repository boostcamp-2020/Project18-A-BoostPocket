//
//  CountryProvider.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
import CoreData

protocol CountryProvidable: AnyObject {
    var countries: [Country]? { get }
    func fetchCountries() -> [Country]?
    @discardableResult func createCountry(name: String, lastUpdated: Date, flagImage: Data, exchangeRate: Double, currencyCode: String) -> Country?
}

class CountryProvider: CountryProvidable {

    private weak var persistenceManager: PersistenceManagable?
    var countries: [Country]?
    
    init(persistenceManager: PersistenceManagable) {
        self.persistenceManager = persistenceManager
    }
    
    func fetchCountries() -> [Country]? {
        countries = persistenceManager?.fetch(request: Country.fetchRequest())
        return countries
    }
    
    @discardableResult
    func createCountry(name: String, lastUpdated: Date, flagImage: Data, exchangeRate: Double, currencyCode: String) -> Country? {
        guard let persistenceManager = persistenceManager,
              let entity = NSEntityDescription.entity(forEntityName: "Country", in: persistenceManager.context)
              else { return nil }
            let newCountry = Country(entity: entity, insertInto: persistenceManager.context)
        
        newCountry.name = name
        newCountry.lastUpdated = lastUpdated
        newCountry.flagImage = flagImage
        newCountry.exchangeRate = exchangeRate
        newCountry.currencyCode = currencyCode
        
        if persistenceManager.saveContext() {
            countries?.append(newCountry)
            return newCountry
        }
        return nil
    }
}
