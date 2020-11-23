//
//  CountryCell.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class CountryCell: UITableViewCell {
    static let identifier = "CountryCell"

    @IBOutlet weak var countryNameLabel: UILabel!

    func configure(with countryName: String) {
        countryNameLabel.text = countryName
    }
}
