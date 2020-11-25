//
//  TravelItemViewModel.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol TravelItemPresentable {
    var id: UUID? { get }
    var title: String? { get }
    var memo: String? { get }
    var exchangeRate: Double { get }
    var budget: Double { get }
    var coverImage: Data? { get }
    var startDate: Date? { get }
    var endDate: Date? { get }
    var countryName: String? { get }
    var flagImage: Data? { get }
    var currencyCode: String? { get }
}

struct TravelItemViewModel: TravelItemPresentable, Equatable, Hashable {
    var id: UUID?
    var title: String?
    var memo: String?
    var exchangeRate: Double
    var budget: Double
    var coverImage: Data?
    var startDate: Date?
    var endDate: Date?
    var countryName: String?
    var flagImage: Data?
    var currencyCode: String?
    
    init(travel: TravelProtocol) {
        self.id = travel.id
        self.title = travel.title
        self.memo = travel.memo
        self.exchangeRate = travel.exchangeRate
        self.budget = travel.budget
        self.coverImage = travel.coverImage
        self.startDate = travel.startDate
        self.endDate = travel.endDate
        self.countryName = travel.country?.name
        self.flagImage = travel.country?.flagImage
        self.currencyCode = travel.country?.currencyCode
    }
}
