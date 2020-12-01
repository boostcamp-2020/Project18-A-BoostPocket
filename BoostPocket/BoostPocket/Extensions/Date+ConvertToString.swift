//
//  Date+ConvertToString.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/26.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

enum DateFormats: String {
    case dotted = "yyyy. MM. dd."
    case dashed = "yyyy-MM-dd."
    case korean = "yyyy년 MM월 dd일"
}

extension Date {
    func convertToString(format: DateFormats) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}

extension String {
    func convertToDate() -> Date {
        let dateString :String = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        let date: Date = dateFormatter.date(from: dateString)!
        return date
    }
}
