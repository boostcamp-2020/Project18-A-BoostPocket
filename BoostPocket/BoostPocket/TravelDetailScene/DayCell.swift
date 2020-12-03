//
//  DayCell.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class DayCell: UIView {
    
    var dayButton: UIButton = UIButton()
    var monthLabel: UILabel = UILabel()
    
    init(frame: CGRect, date: Date) {
        super.init(frame: frame)
        configure(with: date)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(with: Date())
    }
    
    func configure(with date: Date) {
        dayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        dayButton.setTitleColor(.black, for: .normal)
        monthLabel.font = monthLabel.font.withSize(10)
        monthLabel.textColor = UIColor.lightGray

        dayButton.setTitle(date.convertToString(format: .day), for: .normal)
        monthLabel.text = date.convertToString(format: .month)
        addSubview(dayButton)
        addSubview(monthLabel)
        
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dayButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dayButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 12)
        ])
    }
}
