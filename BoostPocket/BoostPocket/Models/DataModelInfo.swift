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
        self.coverImage = coverImage
        self.budget = budget
        self.exchangeRate = exchangeRate
    }
}

enum HistoryCategory: Int16 {
    case income = 0
    case food
    case shopping
    case transportation
    case tourism
    case accommodation
    case etc
    
    var name: String {
        switch self {
        case .income:
            return "예산 금액 추가"
        case .food:
            return "식비"
        case .shopping:
            return "쇼핑"
        case .transportation:
            return "교통"
        case .tourism:
            return "관광"
        case .accommodation:
            return "숙박"
        case .etc:
            return "기타"
        }
    }
}

struct HistoryInfo {
    private(set) var travelId: UUID
    private(set) var id: UUID
    private(set) var isIncome: Bool
    private(set) var title: String
    private(set) var memo: String?
    private(set) var date: Date
    private(set) var category: HistoryCategory
    private(set) var amount: Double
    private(set) var image: Data?
    private(set) var isPrepare: Bool?
    private(set) var isCard: Bool?
}
