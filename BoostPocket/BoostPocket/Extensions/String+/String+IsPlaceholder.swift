//
//  String+IsPlaceholder.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/08.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

extension String {
    func isPlaceholder() -> Bool {
        return self == EditMemoType.travelMemo.rawValue
            || self == EditMemoType.expenseMemo.rawValue
            || self == EditMemoType.incomeMemo.rawValue
            || self == "항목명을 입력해주세요 (선택)"
    }
}
