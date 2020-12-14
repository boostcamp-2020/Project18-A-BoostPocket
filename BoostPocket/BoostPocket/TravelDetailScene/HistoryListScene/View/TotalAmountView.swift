//
//  TotalAmountView.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TotalAmountView: UIView {
    
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var remainLabel: UILabel!
    @IBOutlet weak var expenseTitleLabel: UILabel!
    @IBOutlet weak var remainTitleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var expenseTitleLabelHalfCenterX: NSLayoutConstraint!
    @IBOutlet weak var expenseTitleLabelCenterX: NSLayoutConstraint!
    @IBOutlet weak var expenseLabelHalfWidth: NSLayoutConstraint!
    @IBOutlet weak var expenseLabelFullWidth: NSLayoutConstraint!
    
    func configure(withExpense expense: Double, income: Double, identifier: String?) {
        let remain = income - expense
        if income == 0 {
            hideRemainLabels()
        } else {
            showRemainLabels()
            remainLabel.text = setLabel(with: identifier, amount: remain)
            remainLabel.textColor = remain < 0 ? UIColor(named: "deleteTextColor") : UIColor(named: "detailIncomeColor")
        }
        expenseLabel.text = setLabel(with: identifier, amount: expense)
        expenseLabel.textColor = .black

    }
    
    private func setLabel(with identifier: String?, amount: Double) -> String {
        let signResult = amount >= 0 ? "" : "-"
        if let id = identifier {
            return signResult + id.currencySymbol + " " + abs(amount).getCurrencyFormat(identifier: id)
        }
        return amount.insertComma
    }
    
    func hideRemainLabels() {
        remainLabel.isHidden = true
        remainTitleLabel.isHidden = true
        divider.isHidden = true

        expenseTitleLabelHalfCenterX.priority = UILayoutPriority(750)
        expenseTitleLabelCenterX.priority = UILayoutPriority(1000)
        expenseLabelHalfWidth.priority = UILayoutPriority(750)
        expenseLabelFullWidth.priority = UILayoutPriority(1000)
    }
    
    func showRemainLabels() {
        remainLabel.isHidden = false
        remainTitleLabel.isHidden = false
        divider.isHidden = false
        
        expenseTitleLabelCenterX.priority = UILayoutPriority(750)
        expenseTitleLabelHalfCenterX.priority = UILayoutPriority(1000)
        expenseLabelFullWidth.priority = UILayoutPriority(750)
        expenseLabelHalfWidth.priority = UILayoutPriority(1000)
    }
}
