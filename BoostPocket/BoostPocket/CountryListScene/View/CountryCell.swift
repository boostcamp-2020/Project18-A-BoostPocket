//
//  CountryCell.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit
import FlagKit

class CountryCell: UITableViewCell {
    static let identifier = "CountryCell"

    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryFlagImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
    }
    
    func configure(with country: CountryItemViewModel) {
        countryNameLabel.text = country.name
        guard let flagImage = UIImage(data: country.flag) else { return }
        countryFlagImageView.image = flagImage
    }
}
