//
//  CountryViewModel.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol CountryItemPresentable {
    var name: String { get }
    var flag: Data { get }
    var currencyCode: String { get }
}

struct CountryItemViewModel: CountryItemPresentable, Equatable {
    var name: String
    var flag: Data
    var currencyCode: String
    
    init(country: CountryProtocol) {
        self.name = country.name ?? ""
        self.flag = country.flagImage ?? Data()
        self.currencyCode = country.currencyCode ?? ""
    }
    
}
