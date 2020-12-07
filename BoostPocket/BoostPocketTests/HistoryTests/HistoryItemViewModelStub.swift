//
//  HistoryItemViewModelStub.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

class HistoryItemViewModelStub: HistoryItemViewModel {
    override init(history: HistoryProtocol) {
        super.init(history: history)
        self.id = history.id
        self.isIncome = history.isIncome
        self.category = history.categoryState
        self.title = history.title ?? history.categoryState.name
        self.memo = history.memo
        self.amount = history.amount
        self.image = history.image
        self.date = history.date ?? Date()
        self.isCard = history.isCard
        self.isPrepare = history.isPrepare
    }
}

class HistoryStub: HistoryProtocol {
    var id: UUID?
    var isIncome: Bool
    var title: String?
    var memo: String?
    var amount: Double
    var isCard: Bool
    var category: Int16
    var isPrepare: Bool
    var image: Data?
    var date: Date?
    var travel: Travel?
    var categoryState: HistoryCategory
    
    init(id: UUID?, isIncome: Bool, title: String, memo: String?, amount: Double, image: Data?, date: Date, category: Int16, isCard: Bool?, isPrepare: Bool?) {
        self.id = id
        self.isIncome = isIncome
        self.title = title
        self.memo = memo
        self.amount = amount
        self.image = image
        self.date = date
        self.category = category
        self.isCard = isCard ?? false
        self.isPrepare = isPrepare ?? false
        self.categoryState = .etc
    }
}
