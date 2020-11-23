//
//  Travel+CoreDataProperties.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//
//

import Foundation
import CoreData


extension Travel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Travel> {
        return NSFetchRequest<Travel>(entityName: "Travel")
    }

    @NSManaged public var budget: Double
    @NSManaged public var coverImage: Data?
    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var memo: String?
    @NSManaged public var title: String?
    @NSManaged public var exchangeRate: Double
    @NSManaged public var country: Country?

}
