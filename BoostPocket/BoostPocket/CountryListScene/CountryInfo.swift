//
//  CountryInfo.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

enum InformationType {
    case CountryInfo
    case TravelInfo
    case HistoryInfo
}

protocol InformationProtocol {
    var informationType: InformationType { get }
}

struct CountryInfo: InformationProtocol {
    private(set) var informationType: InformationType = .CountryInfo
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
