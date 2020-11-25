//
//  CountryInfo.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

class CountryInfo {
    var name: String
    var lastUpdated: Date
    var flagImage: Data
    var currencyCode: String
    var exchangeRate: Double
    
    init(name: String, lastUpdated: Date, flagImage: Data, exchangeRate: Double, currencyCode: String ) {
        self.name = name
        self.lastUpdated = lastUpdated
        self.flagImage = flagImage
        self.currencyCode = currencyCode
        self.exchangeRate = exchangeRate
    }
}
