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
    
    func configure(with day: Int?, date: Date, amount: Double?) {
        if let day = day, day > 0 {
            dayLabel.text = "DAY \(day)"
        } else {
            dayLabel.text = ""
        }
        dateLabel.text = date.convertToString(format: .korean)
        guard let amount = amount else { return }
        amountLabel.text = "₩" + amount.insertComma
    }
    
    static func getNib() -> UINib {
        return UINib(nibName: HistoryHeaderCell.identifier, bundle: nil)
    }
}
