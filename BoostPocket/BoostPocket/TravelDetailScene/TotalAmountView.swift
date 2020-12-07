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
    @IBOutlet weak var expenseTitleLabelOriginCenterX: NSLayoutConstraint?
    weak var expenseTitleLabelCenterX: NSLayoutConstraint?
    
    func configure(withExpense expense: Double, remain: Double) {
        if remain == 0 {
            hideRemainLabels()
        } else {
            showRemainLabels()
            remainLabel.text = String(remain)
        }
        expenseLabel.text = String(expense)
    }
    
    func hideRemainLabels() {
        remainLabel.isHidden = true
        remainTitleLabel.isHidden = true
        divider.isHidden = true
        
        expenseTitleLabelCenterX?.isActive = false
        expenseTitleLabelOriginCenterX?.isActive = false
        
        expenseTitleLabelCenterX = NSLayoutConstraint(item: expenseTitleLabel ?? UILabel(), attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        expenseTitleLabelCenterX?.isActive = true
    }
    
    func showRemainLabels() {
        remainLabel.isHidden = false
        remainTitleLabel.isHidden = false
        divider.isHidden = false
        
        expenseTitleLabelCenterX?.isActive = false
        expenseTitleLabelOriginCenterX?.isActive = false
        
        expenseTitleLabelOriginCenterX = NSLayoutConstraint(item: expenseTitleLabel ?? UILabel(), attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 0.5, constant: 0)
        expenseTitleLabelOriginCenterX?.isActive = true
    }
}
