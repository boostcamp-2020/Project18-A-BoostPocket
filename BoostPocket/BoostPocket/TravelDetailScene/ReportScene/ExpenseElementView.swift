//
//  ExpenseElementView.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/09.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

struct ExpenseElementViewModel {
    var category: HistoryCategory
    var categoryPercentage: Double
    var currencyCode: String
    var expense: String
    var expenseKRW: String
}

class ExpenseElementView: UIView {
    static let identifier = "ExpenseElementView"
    
    @IBOutlet weak var categoryBackgroundView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var expenseKRWLabel: UILabel!
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    
    func configure(with expenseElement: ExpenseElementViewModel) {
        let categoryColor = UIColor(named: expenseElement.category.imageName + "-color") ?? UIColor.systemBlue
        
        categoryBackgroundView.backgroundColor = categoryColor
        categoryBackgroundView.layer.cornerRadius = categoryBackgroundView.frame.width * 0.5
        
        categoryImageView.image = UIImage(named: expenseElement.category.imageName + "-report")
        
        expenseKRWLabel.text = expenseElement.expenseKRW
        expenseLabel.text = expenseElement.expense
        currencyCodeLabel.text = expenseElement.currencyCode
        categoryNameLabel.text = expenseElement.category.name + " " + String(format: "%.f%%", expenseElement.categoryPercentage)
        categoryNameLabel.textColor = categoryColor
    }

}
