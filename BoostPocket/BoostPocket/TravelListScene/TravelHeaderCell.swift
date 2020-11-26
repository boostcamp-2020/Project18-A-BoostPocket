//
//  TravelHeaderCell.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/26.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TravelHeaderCell: UICollectionReusableView {
    
    static let identifier = "TravelHeaderCell"
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with header: String) {
        headerLabel.text = header
    }
    
    static func getNib() -> UINib {
        return UINib(nibName: TravelHeaderCell.identifier, bundle: nil)
    }
}
