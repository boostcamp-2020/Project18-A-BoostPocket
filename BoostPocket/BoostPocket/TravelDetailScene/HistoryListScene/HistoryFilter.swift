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
    
    func filterHistories(with histories: [HistoryItemViewModel]?) -> [HistoryItemViewModel] {
        guard var filteredHistories = histories else { return [] }
        if let card = isCardOnly {
            filteredHistories = filteredHistories.filter { $0.isCard == card }
        }
        if let prepare = isPrepareOnly, prepare {
            filteredHistories = filteredHistories.filter { $0.isPrepare == prepare }
        } else if let date = selectedDate {
            filteredHistories = filteredHistories.filter { date.convertToString(format: .dotted) == $0.date.convertToString(format: .dotted)}
        }
        return filteredHistories
    }
}
