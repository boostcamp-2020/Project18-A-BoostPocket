//
//  Travel+CoreDataProperties.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/25.
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
    @NSManaged public var exchangeRate: Double
    @NSManaged public var memo: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var id: UUID?
    @NSManaged public var country: Country?
    @NSManaged public var history: NSSet?

}

// MARK: Generated accessors for history
extension Travel {

    @objc(addHistoryObject:)
    @NSManaged public func addToHistory(_ value: History)

    @objc(removeHistoryObject:)
    @NSManaged public func removeFromHistory(_ value: History)

    @objc(addHistory:)
    @NSManaged public func addToHistory(_ values: NSSet)

    @objc(removeHistory:)
    @NSManaged public func removeFromHistory(_ values: NSSet)

}

extension Travel: Identifiable {

}
