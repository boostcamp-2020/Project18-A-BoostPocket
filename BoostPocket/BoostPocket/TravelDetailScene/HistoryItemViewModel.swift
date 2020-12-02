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
    var memo: String { get }
    var amount: Double { get }
    var image: Data? { get }
    var date: Date { get }
    var category: HistoryCategory { get }
    var isCard: Bool? { get }
    var isPrepare: Bool? { get }
}
