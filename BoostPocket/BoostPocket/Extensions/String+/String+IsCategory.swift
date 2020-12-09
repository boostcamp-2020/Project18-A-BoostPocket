//
//  String+IsCategory.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/08.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension String {
    func isCategory() -> Bool {
        var isCategory: Bool = false
        HistoryCategory.allCases.forEach { category in
            if self == category.name { isCategory = true }
        }
        
        return isCategory
    }
}
