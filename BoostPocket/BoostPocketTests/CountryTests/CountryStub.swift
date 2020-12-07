//
//  CountryStub.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
@testable import BoostPocket

class CountryStub: CountryProtocol {
    var name: String?
    var flagImage: Data?
    var currencyCode: String?
    
    init(name: String?, flagImage: Data?, currencyCode: String?) {
        self.name = name
        self.flagImage = flagImage
        self.currencyCode = currencyCode
    }
}

class CountryProviderStub: CountryProvider {
    private weak var persistenceManager: PersistenceManagable?

    override init(persistenceManager: PersistenceManagable) {
        super.init(persistenceManager: persistenceManager)
        self.persistenceManager = persistenceManager
    }

    func createCountry(name: String, lastUpdated: Date, flagImage: Data, exchangeRate: Double, currencyCode: String, identifier: String, completion: @escaping (Country?) -> Void) {
        let newCountryInfo = CountryInfo(name: name,
                                         lastUpdated: lastUpdated,
                                         flagImage: flagImage,
                                         exchangeRate: exchangeRate,
                                         currencyCode: currencyCode,
                                         identifier: identifier)

        persistenceManager?.createObject(newObjectInfo: newCountryInfo, completion: { (createdObject) in
            guard let createdCountry = createdObject as? Country else {
                completion(nil)
                return
            }
            completion(createdCountry)
        })
    }
}

class CountryListViewModelStub: CountryListViewModel {
    var countryProvider: CountryProviderStub?

    override init(countryProvider: CountryProvidable) {
        super.init(countryProvider: countryProvider)
        self.countryProvider = countryProvider as? CountryProviderStub
    }

    func createCountry(name: String, lastUpdated: Date, flagImage: Data, exchangeRate: Double, currencyCode: String, identifier: String) {
        countryProvider?.createCountry(name: name, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier) { [weak self] (createdCountry) in
            guard let createdCountry = createdCountry else { return }
            
            let createdCountryItemViewModel = CountryItemViewModel(country: createdCountry)
            self?.countries.append(createdCountryItemViewModel)
        }
    }
}
