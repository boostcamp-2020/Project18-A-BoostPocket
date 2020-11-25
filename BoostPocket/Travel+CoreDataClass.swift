//
//  Travel+CoreDataClass.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//
//

import Foundation
import CoreData

protocol TravelProtocol {
    var id: UUID? { get }
    var title: String? { get }
    var memo: String? { get }
    var exchangeRate: Double { get }
    var budget: Double { get }
    var coverImage: Data? { get }
    var startDate: Date? { get }
    var endDate: Date? { get }
    var country: Country? { get }
}

@objc(Travel)
public class Travel: NSManagedObject, TravelProtocol, DataModelProtocol {
    static let entityName = "Travel"
}
