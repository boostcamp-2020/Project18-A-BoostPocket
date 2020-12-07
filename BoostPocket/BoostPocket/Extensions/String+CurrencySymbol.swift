//
//  Locale+CurrencySymbol.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension String {
    
    var currencySymbol: String {
        let locale = NSLocale(localeIdentifier: self)
        return locale.currencySymbol
    }
    
//    func getSymbolForCurrencyCode() -> String {
//        let result = Locale.availableIdentifiers.map { Locale(identifier: $0) }.first { $0.currencyCode == self }
//        
//        guard let currencySymbol = result?.currencySymbol else { return self }
//        return currencySymbol
//    }
}
