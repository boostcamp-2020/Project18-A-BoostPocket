//
//  Double+Comma.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension Double {
    var insertComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let result = numberFormatter.string(from: NSNumber(value: self)) else { return "" }
        return result
    }
}
