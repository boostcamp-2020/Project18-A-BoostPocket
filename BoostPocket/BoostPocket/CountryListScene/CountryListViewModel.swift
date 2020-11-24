//
//  CountryListViewModel.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol CountryListPresentable: AnyObject {
    var countries: [CountryItemPresentable] { get }
    var didFetch: (() -> Void)? { get set }
    
    func needFetchItems()
    func cellForItemAt(path: IndexPath) -> CountryItemPresentable
    func numberOfItem() -> Int
}

class CountryListViewModel: CountryListPresentable {
    var didFetch: (() -> Void)?
    var countries: [CountryItemPresentable] = []
    private var countryProvider: CountryProvidable?
    
    init(countryProvider: CountryProvidable) {
        self.countryProvider = countryProvider
    }
    
    func needFetchItems() {
        let fetchedCountries = countryProvider?.fetchCountries()
        fetchedCountries?.forEach { country in
            self.countries.append(CountryItemViewModel(country: country))
        }
            
        DispatchQueue.main.async { [weak self] in
            self?.didFetch?()
        }
    }
    
    func cellForItemAt(path: IndexPath) -> CountryItemPresentable {
        return countries[path.row]
    }
    
    func numberOfItem() -> Int {
        return countries.count
    }
}
