//
//  HistoryProvider.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol HistoryProvidable: AnyObject {
    var histories: [History] { get }
    func createHistory(createdHistoryInfo: HistoryInfo, completion: @escaping (History?) -> Void)
    func fetchHistories() -> [History]
    func deleteHistory(id: UUID) -> Bool
    func updateHistory(updatedHistoryInfo: HistoryInfo) -> History?
}

