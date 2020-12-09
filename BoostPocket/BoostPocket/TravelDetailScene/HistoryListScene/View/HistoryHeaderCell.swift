//
//  HistoryHeaderCell.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class HistoryHeaderCell: UITableViewHeaderFooterView {
    
    static let identifier = "HistoryHeaderCell"
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabelLeadingConstraint: NSLayoutConstraint!
    
    func configure(with day: Int?, date: Date, amount: Double?) {
        // TODO: - 여행 기간 이후에 해당하는 날짜 처리
        if let day = day, day > 0 {
            dayLabel.text = "DAY \(day)"
            dateLabelLeadingConstraint.constant = 30
        } else {
            dayLabel.text = ""
            dateLabelLeadingConstraint.constant = 0
        }
        dateLabel.text = date.convertToString(format: .korean)
        guard let amount = amount else { return }
        amountLabel.text = "₩ " + amount.insertComma
    }
    
    static func getNib() -> UINib {
        return UINib(nibName: HistoryHeaderCell.identifier, bundle: nil)
    }
}
