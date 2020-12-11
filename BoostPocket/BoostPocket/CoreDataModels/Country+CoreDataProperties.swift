//
//  Country+CoreDataProperties.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//
//

import Foundation
import CoreData

extension Country {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Country> {
        return NSFetchRequest<Country>(entityName: "Country")
    }

    @NSManaged public var currencyCode: String?
    @NSManaged public var exchangeRate: Double
    @NSManaged public var flagImage: Data?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var identifier: String?
    @NSManaged public var travels: NSSet?

}

// MARK: Generated accessors for travels
extension Country {

    @objc(addTravelsObject:)
    @NSManaged public func addToTravels(_ value: Travel)

    @objc(removeTravelsObject:)
    @NSManaged public func removeFromTravels(_ value: Travel)

    @objc(addTravels:)
    @NSManaged public func addToTravels(_ values: NSSet)

    @objc(removeTravels:)
    @NSManaged public func removeFromTravels(_ values: NSSet)

}
