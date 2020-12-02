//
//  HistoryCell.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with history: HistoryItemViewModel) {
        categoryImageView.image = UIImage(named: history.category.name)
        costLabel.text = "\(history.amount)"
        titleLabel.text = history.title
        dateLabel.text = history.date.convertToString(format: .dotted)
    }
    
}
