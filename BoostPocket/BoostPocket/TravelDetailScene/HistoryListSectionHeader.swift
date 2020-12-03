//
//  HistoryListSectionHeader.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

class HistoryListSectionHeader: Hashable {
    static func == (lhs: HistoryListSectionHeader, rhs: HistoryListSectionHeader) -> Bool {
        return lhs.dayNumber == rhs.dayNumber
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dayNumber)
    }
    
    var dayNumber: Int?
    var date: Date
    var amount: Double
    
    init(dayNumber: Int?, date: Date, amount: Double) {
        self.dayNumber = dayNumber
        self.date = date
        self.amount = amount
    }
}
