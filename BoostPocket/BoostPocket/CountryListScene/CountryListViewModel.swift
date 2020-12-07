//
//  CountryListViewModel.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol CountryListPresentable: AnyObject {
    var countries: [CountryItemViewModel] { get }
    var didFetch: (([CountryItemViewModel]) -> Void)? { get set }
    
    func needFetchItems()
    func numberOfItem() -> Int
}

class CountryListViewModel: CountryListPresentable {
    var didFetch: (([CountryItemViewModel]) -> Void)?
    var countries: [CountryItemViewModel] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.didFetch?(self?.countries ?? [])
            }
        }
    }
    private weak var countryProvider: CountryProvidable?
    
    init(countryProvider: CountryProvidable) {
        self.countryProvider = countryProvider
    }
    
    func needFetchItems() {
        guard let fetchedCountries = countryProvider?.fetchCountries() else { return }
        self.countries.removeAll()
        var newCountryItemViewModels: [CountryItemViewModel] = []
        fetchedCountries.forEach { country in
            newCountryItemViewModels.append(CountryItemViewModel(country: country))
        }
        countries = newCountryItemViewModels
    }
    
    func numberOfItem() -> Int {
        return countries.count
    }
}
