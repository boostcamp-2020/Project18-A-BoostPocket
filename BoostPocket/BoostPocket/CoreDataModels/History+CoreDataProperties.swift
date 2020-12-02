//
//  History+CoreDataProperties.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isIncome: Bool
    @NSManaged public var title: String?
    @NSManaged public var memo: String?
    @NSManaged public var amount: Double
    @NSManaged public var isCard: Bool
    @NSManaged public var category: Int16
    @NSManaged public var isPrepare: Bool
    @NSManaged public var image: Data?
    @NSManaged public var date: Date?
    @NSManaged public var travel: Travel?

}

extension History : Identifiable {

}
