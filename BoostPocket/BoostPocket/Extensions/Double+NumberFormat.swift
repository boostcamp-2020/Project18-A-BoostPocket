//
//  Double+NumberFormat.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension Double {
    
    func getCurrencyFormat(currencyCode: String) -> String {
        let locale = Locale.availableIdentifiers.map { Locale(identifier: $0) }.first { $0.currencyCode == currencyCode }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = locale
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: self)) else { return String(self) }
        return formattedNumber
    }
}
