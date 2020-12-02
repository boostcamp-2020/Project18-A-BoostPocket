//
//  HistoryListviewModel.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol HistoryListPresentable {
    var histories: [HistoryItemViewModel] { get }
    var didFetch: (([HistoryItemViewModel]) -> Void)? { get set }
    func createHistory(id: UUID, isIncome: Bool, title: String, memo: String?, date: Date?, image: Data, amount: Double,
                       category: HistoryCategory, isPrepare: Bool, isCard: Bool, completion: @escaping (HistoryItemViewModel?) -> Void)
    func needFetchItems()
    func updateHistory(id: UUID, isIncome: Bool, title: String, memo: String?, date: Date?, image: Data, amount: Double,
                       category: HistoryCategory, isPrepare: Bool, isCard: Bool) -> Bool
    func deleteHistory(id: UUID) -> Bool
    func numberOfItem() -> Int
}
