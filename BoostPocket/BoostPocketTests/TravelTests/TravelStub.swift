//
//  TravelStub.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
@testable import BoostPocket

class TravelStub: TravelProtocol {
    var id: UUID?
    var title: String?
    var memo: String?
    var exchangeRate: Double
    var budget: Double
    var coverImage: Data?
    var startDate: Date?
    var endDate: Date?
    var country: Country?
    
    init(id: UUID?, title: String?, memo: String?, exchangeRate: Double, budget: Double, coverImage: Data?, startDate: Date?, endDate: Date?, country: Country?) {
        self.id = id
        self.title = title
        self.memo = memo
        self.exchangeRate = exchangeRate
        self.budget = budget
        self.coverImage = coverImage
        self.startDate = startDate
        self.endDate = endDate
        self.country = country
    }
    
}
