//
//  HistoryFilter.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

class HistoryFilter {
    private var _isPrepareOnly: Bool?
    private var _selectedDate: Date?
    private var _isCardOnly: Bool?
    
    var isPrepareOnly: Bool? {
        get { return _isPrepareOnly }
        set(newValue) { self._isPrepareOnly = newValue }
    }
    
    var selectedDate: Date? {
        get { return _selectedDate }
        set(newValue) { self._selectedDate = newValue }
    }
    
    var isCardOnly: Bool? {
        get { return _isCardOnly }
        set(newValue) { self._isCardOnly = newValue }
    }
    
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
