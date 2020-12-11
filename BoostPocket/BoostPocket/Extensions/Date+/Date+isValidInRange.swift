//
//  Date+isValidInRange.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/11.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension Date {
    
    func isValidInRange(from startDate: Date, to endDate: Date) -> Bool {
        
        let myDate = self.convertToString(format: .dashed).convertToDate()
        var date = startDate.convertToString(format: .dashed).convertToDate()
        let convertedEndDate = endDate.convertToString(format: .dashed).convertToDate()

        while date <= convertedEndDate {
            guard !myDate.isSameDay(with: date) else { return true }

            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return false
    }
    
}
