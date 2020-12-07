//
//  CountryStub.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
@testable import BoostPocket

class CountryStub: CountryProtocol {
    var name: String?
    var flagImage: Data?
    var currencyCode: String?
    
    init(name: String?, flagImage: Data?, currencyCode: String?) {
        self.name = name
        self.flagImage = flagImage
        self.currencyCode = currencyCode
    }
}
