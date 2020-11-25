//
//  String+Extension.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/24.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension String {
    
    var firstConsonant: String {
        guard let value = UnicodeScalar(self)?.value else { return "대" }
        let x = (value - 0xac00) / 28 / 21
        guard let first = UnicodeScalar(0x1100 + x) else { return "ㄱ" }
        return String(first)
    }
}
