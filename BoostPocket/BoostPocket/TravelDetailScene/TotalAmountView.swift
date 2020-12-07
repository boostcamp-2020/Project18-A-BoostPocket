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
    
    // TODO: - expenseTitleLabelCenterX weak 참조 하고 코드로 multiplier constraint 잡아보기
    @IBOutlet var expenseTitleLabelCenterX: NSLayoutConstraint?
    weak var expenseTitleLabelCenterX2: NSLayoutConstraint?
    
    func hideRemainLabels() {
        remainLabel.isHidden = true
        remainTitleLabel.isHidden = true
        divider.isHidden = true
        
        expenseTitleLabelCenterX?.isActive = false
        
        expenseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        expenseTitleLabelCenterX2 = expenseTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        expenseTitleLabelCenterX2?.isActive = true
    }
    
    func showRemainLabels() {
        remainLabel.isHidden = false
        remainTitleLabel.isHidden = false
        divider.isHidden = false
        
        expenseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        expenseTitleLabelCenterX2?.isActive = false
        expenseTitleLabelCenterX?.isActive = true
    }
}
