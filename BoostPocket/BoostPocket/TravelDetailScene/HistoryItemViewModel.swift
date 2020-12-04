//
//  HistoryItemViewModel.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol HistoryItemPresentable: AnyObject {
    var id: UUID? { get }
    var isIncome: Bool { get }
    var title: String { get }
    var memo: String? { get }
    var amount: Double { get }
    var image: Data? { get }
    var date: Date { get }
    var category: HistoryCategory { get }
    var isCard: Bool? { get }
    var isPrepare: Bool? { get }
}

class HistoryItemViewModel: Equatable, Hashable, HistoryItemPresentable {
    static func == (lhs: HistoryItemViewModel, rhs: HistoryItemViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID?
    var isIncome: Bool
    var title: String
    var memo: String?
    var amount: Double
    var image: Data?
    var date: Date
    var category: HistoryCategory
    var isCard: Bool?
    var isPrepare: Bool?
    
    init(history: HistoryProtocol) {
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
