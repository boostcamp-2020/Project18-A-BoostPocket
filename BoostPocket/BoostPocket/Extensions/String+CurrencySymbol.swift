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
}
