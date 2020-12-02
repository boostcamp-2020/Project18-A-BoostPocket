//
//  TravelItemViewModel.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol TravelItemPresentable: AnyObject {
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

class TravelItemViewModel: TravelItemPresentable, Equatable, Hashable {
    static func == (lhs: TravelItemViewModel, rhs: TravelItemViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private weak var historyProvider: HistoryProvidable?
    var histories: [HistoryItemViewModel] = []
    var didFetch: (([HistoryItemViewModel]) -> Void)?
    
    var id: UUID?
    var title: String?
    var memo: String?
    var exchangeRate: Double
    var budget: Double = 0.0
    var coverImage: Data?
    var startDate: Date?
    var endDate: Date?
    var countryName: String?
    var flagImage: Data?
    var currencyCode: String?
    
    init(travel: TravelProtocol, historyProvider: HistoryProvidable) {
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
        
        self.historyProvider = historyProvider
    }
}

extension TravelItemViewModel: HistoryListPresentable {
    
    func createHistory(id: UUID, isIncome: Bool, title: String, memo: String?, date: Date?, image: Data, amount: Double, category: HistoryCategory, isPrepare: Bool, isCard: Bool, completion: @escaping (HistoryItemViewModel?) -> Void) {
        
        let historyInfo = HistoryInfo(travelId: self.id ?? UUID(), id: id, isIncome: isIncome, title: title, memo: memo, date: date ?? Date(), category: category, amount: amount, image: image, isPrepare: isPrepare, isCard: isCard)
        
        historyProvider?.createHistory(createdHistoryInfo: historyInfo) { history in
            guard let createdHistory = history else {
                completion(nil)
                return
            }
            let createdHistoryItemViewModel = HistoryItemViewModel(history: createdHistory)
            self.histories.append(createdHistoryItemViewModel)
            completion(createdHistoryItemViewModel)
        }
    }
    
    func needFetchItems() {
        guard let fetchedHistories = historyProvider?.fetchHistories() else { return }
        
        histories.removeAll()
        var newHistoryItemViewModels: [HistoryItemViewModel] = []
        fetchedHistories.forEach { history in
            newHistoryItemViewModels.append(HistoryItemViewModel(history: history))
        }
        
        histories = newHistoryItemViewModels
    }
    
    func updateHistory(id: UUID, isIncome: Bool, title: String, memo: String?, date: Date?, image: Data?, amount: Double, category: HistoryCategory, isPrepare: Bool?, isCard: Bool?) -> Bool {
        
        let historyInfo = HistoryInfo(travelId: self.id ?? UUID(), id: id, isIncome: isIncome, title: title, memo: memo, date: date ?? Date(), category: category, amount: amount, image: image, isPrepare: isPrepare, isCard: isCard)
        
        guard let updatedHistory = historyProvider?.updateHistory(updatedHistoryInfo: historyInfo),
            let indexToUpdate = histories.indices.filter({ histories[$0].id == updatedHistory.id }).first
            else { return false }
        
        histories[indexToUpdate].amount = updatedHistory.amount
        histories[indexToUpdate].category = updatedHistory.categoryState
        histories[indexToUpdate].date = updatedHistory.date ?? Date()
        histories[indexToUpdate].image = updatedHistory.image
        histories[indexToUpdate].isCard = updatedHistory.isCard
        histories[indexToUpdate].isPrepare = updatedHistory.isPrepare
        histories[indexToUpdate].memo = updatedHistory.memo
        histories[indexToUpdate].title = updatedHistory.title ?? updatedHistory.categoryState.name
        
        return true
    }
    
    func deleteHistory(id: UUID) -> Bool {
        return false
    }
    
    func numberOfItem() -> Int {
        return 0
    }
}
