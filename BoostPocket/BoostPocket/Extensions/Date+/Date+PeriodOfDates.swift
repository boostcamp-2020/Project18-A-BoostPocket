//
//  Date+PeriodOfDates.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension Date {
    func getPeriodOfDates(with endDate: Date) -> [Date] {
        var dates: [Date] = []
        if self.isSameDay(with: endDate) {
            return [self]
        }
        
        var date = self.convertToString(format: .dashed).convertToDate()
        let convertedEndDate = endDate.convertToString(format: .dashed).convertToDate()
        
        print(date)
        print(convertedEndDate)
        
        while date <= convertedEndDate {
            dates.append(date)
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        return dates
    }
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        let currentSelf = self.toLocalTime()
        let currentDate = date.toLocalTime()
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: currentSelf) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: currentDate) else { return 0 }
        
        return end - start
    }
    
    func isSameDay(with date: Date) -> Bool {
        return self.convertToString(format: .dashed) == date.convertToString(format: .dashed)
    }
}
