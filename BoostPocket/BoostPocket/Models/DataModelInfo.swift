//
//  CountryInfo.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

struct CountryInfo {
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

struct TravelInfo {
    private(set) var countryName: String
    private(set) var id: UUID
    private(set) var title: String
    private(set) var memo: String?
    private(set) var startDate: Date?
    private(set) var endDate: Date?
    private(set) var coverImage: Data
    private(set) var budget: Double
    private(set) var exchangeRate: Double
    
    init(countryName: String, id: UUID, title: String, memo: String?, startDate: Date?, endDate: Date?, coverImage: Data, budget: Double, exchangeRate: Double) {
        self.countryName = countryName
        self.id = id
        self.title = title
        self.memo = memo
        self.startDate = startDate
        self.endDate = endDate
        self.coverImage = coverImage.getCoverImage() ?? Data()
        self.budget = budget
        self.exchangeRate = exchangeRate
    }
}
