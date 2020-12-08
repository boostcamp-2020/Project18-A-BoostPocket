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
    
    func configure(withExpense expense: Double, remain: Double) {
        if remain + expense == 0 {
            hideRemainLabels()
        } else {
            showRemainLabels()
            remainLabel.text = String(remain)
            remainLabel.textColor = remain < 0 ? UIColor(named: "deleteTextColor") : UIColor(named: "incomeColor")
        }
        // TODO: identifier 적용하기!
        expenseLabel.text = String(expense)
    }
    
    func hideRemainLabels() {
        remainLabel.isHidden = true
        remainTitleLabel.isHidden = true
        divider.isHidden = true

        expenseTitleLabelHalfCenterX.priority = UILayoutPriority(750)
        expenseTitleLabelCenterX.priority = UILayoutPriority(1000)
    }
    
    func showRemainLabels() {
        remainLabel.isHidden = false
        remainTitleLabel.isHidden = false
        divider.isHidden = false
        
        expenseTitleLabelCenterX.priority = UILayoutPriority(750)
        expenseTitleLabelHalfCenterX.priority = UILayoutPriority(1000)
    }
}
