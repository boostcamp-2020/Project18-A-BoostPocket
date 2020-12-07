//
//  HistoryFilter.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

class HistoryFilter {
    private(set) var isPrepareOnly: Bool?
    private var _selectedDate: Date?
    var selectedDate: Date? {
        get {
            return _selectedDate
        }
        set(newValue) {
            self._selectedDate = newValue
        }
    }
    private(set) var isCardOnly: Bool?
    
    init() {
        self.isPrepareOnly = false
    }
    
    func toggleIsPrepareOnly() {
        isPrepareOnly?.toggle()
    }
    
    func toggleIsCardOnly() {
    }
    
    func resetIsPrepareOnly() {
    }
    
    func resetIsCardOnly() {
    }
    
    func filterHistories(with histories: [HistoryItemViewModel]) -> [HistoryItemViewModel] {
        return []
    }
}
