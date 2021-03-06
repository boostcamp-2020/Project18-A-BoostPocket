//
//  Country+CoreDataClass.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//
//

import Foundation
import CoreData

protocol CountryProtocol {
    var name: String? { get }
    var flagImage: Data? { get }
    var currencyCode: String? { get }
}

protocol DataModelProtocol { }

@objc(Country)
public class Country: NSManagedObject, CountryProtocol, DataModelProtocol {
    static let entityName = "Country"
}
