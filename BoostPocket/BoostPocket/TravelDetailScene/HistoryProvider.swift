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

class HistoryProvider: HistoryProvidable {
    
    var histories: [History] = []
    private weak var persistenceManager: PersistenceManagable?
    
    init(persistenceManager: PersistenceManagable) {
        self.persistenceManager = persistenceManager
    }
    
    func createHistory(createdHistoryInfo: HistoryInfo, completion: @escaping (History?) -> Void) {
        persistenceManager?.createObject(newObjectInfo: createdHistoryInfo) { [weak self] createdObject in
            guard let createdHistory = createdObject as? History else {
                completion(nil)
                return
            }
            self?.histories.append(createdHistory)
            completion(createdHistory)
        }
    }
    
    func fetchHistories() -> [History] {
        guard let persistenceManager = persistenceManager else { return [] }
        histories = persistenceManager.fetchAll(request: History.fetchRequest())
        
        return histories
    }
    
    func deleteHistory(id: UUID) -> Bool {
        return false
    }
    
    func updateHistory(updatedHistoryInfo: HistoryInfo) -> History? {
        return nil
    }
}
