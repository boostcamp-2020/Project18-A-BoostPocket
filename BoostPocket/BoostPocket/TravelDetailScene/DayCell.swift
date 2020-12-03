//
//  DayCell.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class DayCell: UIView {
    
    var dayLabel: UILabel = UILabel()
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
        dayLabel.font = dayLabel.font.withSize(17)
        monthLabel.font = monthLabel.font.withSize(10)
        monthLabel.textColor = UIColor.lightGray
        
        dayLabel.text = date.convertToString(format: .day)
        monthLabel.text = date.convertToString(format: .month)
        addSubview(dayLabel)
        addSubview(monthLabel)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 12)
        ])
    }
}
