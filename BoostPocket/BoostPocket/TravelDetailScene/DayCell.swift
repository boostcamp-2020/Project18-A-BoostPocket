//
//  DayCell.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

protocol DayButtonDelegate: class {
    func dayButtonTapped(_ sender: UIButton)
}

class DayCell: UIView {
    
    var dayButton: UIButton = UIButton()
    var monthLabel: UILabel = UILabel()
    weak var delegate: DayButtonDelegate?
    
    init(frame: CGRect, date: Date) {
        super.init(frame: frame)
        configure(with: date)
        dayButton.addTarget(self, action: #selector(dayButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(with: Date())
        dayButton.addTarget(self, action: #selector(dayButtonTapped), for: .touchUpInside)
    }
    
    func configure(with date: Date) {
        configureDayButton(with: date)
        configureMonthLabel(with: date)
        addSubview(dayButton)
        addSubview(monthLabel)
        addConstraint()
    }
    
    private func configureDayButton(with date: Date) {
        dayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        dayButton.setTitleColor(.black, for: .normal)
        dayButton.setTitle(date.convertToString(format: .day), for: .normal)
    }
    
    private func configureMonthLabel(with date: Date) {
        monthLabel.font = monthLabel.font.withSize(10)
        monthLabel.textColor = UIColor.lightGray
        monthLabel.text = date.convertToString(format: .month)
    }
    
    private func addConstraint() {
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dayButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dayButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -8)
        ])
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 12)
        ])
    }
    
    @objc func dayButtonTapped(_ sender: UIButton) {
        delegate?.dayButtonTapped(sender)
    }
}
