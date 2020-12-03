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
        var date = self
        while date <= endDate {
            dates.append(date)
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        return dates
    }
}
