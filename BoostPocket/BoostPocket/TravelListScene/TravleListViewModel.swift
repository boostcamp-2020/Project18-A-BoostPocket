//
//  TravleListViewModel.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/24.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol TravelListPresentable {
    func createCountryListViewModel() -> CountryListViewModel?
}

class TravelListViewModel: TravelListPresentable {
    private weak var countryProvider: CountryProvidable?
    
    init(countryProvider: CountryProvidable?) {
        self.countryProvider = countryProvider
    }
}

extension TravelListViewModel {
    func createCountryListViewModel() -> CountryListViewModel? {
        guard let countryProvider = countryProvider else { return nil }
        return CountryListViewModel(countryProvider: countryProvider)
    }
}
