//
//  History+CoreDataClass.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//
//

import Foundation
import CoreData

protocol HistoryProtocol {
    var id: UUID? { get }
    var isIncome: Bool { get }
    var title: String? { get }
    var memo: String? { get }
    var amount: Double { get }
    var isCard: Bool { get }
    var category: Int16 { get }
    var isPrepare: Bool { get }
    var image: Data? { get }
    var date: Date? { get }
    var travel: Travel? { get }
    var categoryState: HistoryCategory { get set }
}

@objc(History)
public class History: NSManagedObject, HistoryProtocol, DataModelProtocol {
    static let entityName = "History"
}

extension History {
    var categoryState: HistoryCategory {
        get {
            return HistoryCategory(rawValue: self.category)!
        }
        
        set {
            self.category = newValue.rawValue
        }
    }
}
