//
//  Sections.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/24.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

struct TravelSection: Hashable {
    var travelSectionCase: TravelSectionCase
    var numberOfTravels: Int
}

enum TravelSectionCase {
    case current
    case upcoming
    case past
}
