//
//  CountryInfo.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

enum EntityType {
    case countryType
    case travelType
    case historyType
}

protocol InformationProtocol {
    var informationType: EntityType { get }
}

struct CountryInfo: InformationProtocol {
    private(set) var informationType: EntityType = .countryType
    private(set) var name: String
    private(set) var lastUpdated: Date
    private(set) var flagImage: Data
    private(set) var currencyCode: String
    private(set) var exchangeRate: Double
    
    init(name: String, lastUpdated: Date, flagImage: Data, exchangeRate: Double, currencyCode: String ) {
        self.name = name
        self.lastUpdated = lastUpdated
        self.flagImage = flagImage
        self.currencyCode = currencyCode
        self.exchangeRate = exchangeRate
    }
}

struct TravelInfo: InformationProtocol {
    private(set) var informationType: EntityType = .travelType
    private(set) var countryName: String
    
    init(countryName: String) {
        self.countryName = countryName
    }
}
