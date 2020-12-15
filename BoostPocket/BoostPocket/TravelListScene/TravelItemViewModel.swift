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
    var countryIdentifier: String? { get }
    var expensePercentage: Double { get }
    var getMostSpentCategory: (HistoryCategory, Double) { get }
    func getTotalIncome() -> Double
    func getTotalExpense() -> Double
    func getHistoriesDictionary(from histories: [HistoryItemViewModel]) -> [HistoryCategory: Double]
}

class TravelItemViewModel: TravelItemPresentable, Equatable, Hashable {
    static func == (lhs: TravelItemViewModel, rhs: TravelItemViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private weak var historyProvider: HistoryProvidable?
    
    var histories: [HistoryItemViewModel] = [] {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.didFetch?(newValue)
            }
        }
    }
    
    var didFetch: (([HistoryItemViewModel]) -> Void)?
    
    var expensePercentage: Double {
        let expenses = getTotalExpense()
        let incomes = getTotalIncome()
        
        var percentage: Double
        
        if expenses == 0 {
            return 0
        }
        
        if incomes == 0 {
            return 1
        }
        
        if expenses.isInfinite || expenses.isNaN {
            percentage = 1
        } else if incomes.isInfinite || incomes.isNaN {
            percentage = 0
        } else {
            percentage = Double(expenses / incomes)
        }
        
        return percentage
    }
    
    var getMostSpentCategory: (HistoryCategory, Double) {
        needFetchItems()
        
        let expenses = histories.filter { !$0.isIncome }
        let amounts = getHistoriesDictionary(from: expenses)
        let totalExpense = getTotalExpense()
        
        if let history = expenses.filter({ $0.amount.isNaN || $0.amount.isInfinite }).first {
            return (history.category, 100)
        }
        
        if let (category, amount) = amounts.max(by: {$0.1 < $1.1}) {
            return (category, round(amount / totalExpense * 1000) / 10)
        }
        
        return (HistoryCategory.etc, 0)
    }

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
    var countryIdentifier: String?
    
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
        self.countryIdentifier = travel.country?.identifier
        
        self.historyProvider = historyProvider
    }
    
    func getTotalIncome() -> Double {
        needFetchItems()
        return histories.filter({ $0.isIncome }).reduce(0) { $0 + $1.amount }
    }
    
    func getTotalExpense() -> Double {
        needFetchItems()
        return histories.filter({ !$0.isIncome }).reduce(0) { $0 + $1.amount }
    }
    
    func getHistoriesDictionary(from histories: [HistoryItemViewModel]) -> [HistoryCategory: Double] {
        var counts: [HistoryCategory: Double] = [:]
        histories.forEach { counts[$0.category] = (counts[$0.category] ?? 0) + $0.amount }

        return counts
    }
}

protocol HistoryListPresentable: TravelItemPresentable {
    var histories: [HistoryItemViewModel] { get }
    var didFetch: (([HistoryItemViewModel]) -> Void)? { get set }
    func createHistory(id: UUID, isIncome: Bool, title: String, memo: String?, date: Date?, image: Data?, amount: Double,
                       category: HistoryCategory, isPrepare: Bool, isCard: Bool, completion: @escaping (HistoryItemViewModel?) -> Void)
    func needFetchItems()
    func updateHistory(id: UUID, isIncome: Bool, title: String, memo: String?, date: Date?, image: Data?, amount: Double, category: HistoryCategory, isPrepare: Bool?, isCard: Bool?, completion: @escaping (Bool) -> Void)
    func deleteHistory(id: UUID) -> Bool
    func numberOfItem() -> Int
}

extension TravelItemViewModel: HistoryListPresentable {
    
    func createHistory(id: UUID, isIncome: Bool, title: String, memo: String?, date: Date?, image: Data?, amount: Double, category: HistoryCategory, isPrepare: Bool, isCard: Bool, completion: @escaping (HistoryItemViewModel?) -> Void) {
        
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
        
        var newHistoryItemViewModels: [HistoryItemViewModel] = []
        fetchedHistories.forEach { history in
            if history.travel?.id == self.id {
                newHistoryItemViewModels.append(HistoryItemViewModel(history: history))
            }
        }
        
        histories = newHistoryItemViewModels
    }
    
    func updateHistory(id: UUID, isIncome: Bool, title: String, memo: String?, date: Date?, image: Data?, amount: Double, category: HistoryCategory, isPrepare: Bool?, isCard: Bool?, completion: @escaping (Bool) -> Void) {
        
        let historyInfo = HistoryInfo(travelId: self.id ?? UUID(), id: id, isIncome: isIncome, title: title, memo: memo, date: date ?? Date(), category: category, amount: amount, image: image, isPrepare: isPrepare, isCard: isCard)
        
        historyProvider?.updateHistory(updatedHistoryInfo: historyInfo) { [weak self] updatedHistory in
            guard let self = self,
            let updatedHistory = updatedHistory,
                let indexToUpdate = self.histories.indices.filter({ self.histories[$0].id == updatedHistory.id }).first
                else {
                    completion(false)
                    return
            }
            
            self.histories[indexToUpdate].amount = updatedHistory.amount
            self.histories[indexToUpdate].category = updatedHistory.categoryState
            self.histories[indexToUpdate].date = updatedHistory.date ?? Date()
            self.histories[indexToUpdate].image = updatedHistory.image
            self.histories[indexToUpdate].isCard = updatedHistory.isCard
            self.histories[indexToUpdate].isPrepare = updatedHistory.isPrepare
            self.histories[indexToUpdate].memo = updatedHistory.memo
            self.histories[indexToUpdate].title = updatedHistory.title ?? updatedHistory.categoryState.name
            
            // update 함수는 willSet이 안불리기 때문에 따로 didFetch 처리
            DispatchQueue.main.async {
                self.didFetch?(self.histories)
            }
            
            completion(true)
        }
    }
    
    func deleteHistory(id: UUID) -> Bool {
        if let historyProvider = historyProvider,
            historyProvider.deleteHistory(id: id),
            let indexToDelete = histories.indices.filter({ histories[$0].id == id }).first {
            histories.remove(at: indexToDelete)
            return true
        }
        
        return false
    }
    
    func numberOfItem() -> Int {
        return histories.count
    }
}
