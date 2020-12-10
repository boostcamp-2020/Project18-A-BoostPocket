//
//  Character+isOperation.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/05.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension Character {
    
    func isOperation() -> Bool {
        return self == "+" || self == "-" || self == "*" || self == "/" || self == "."
    }
    
}
