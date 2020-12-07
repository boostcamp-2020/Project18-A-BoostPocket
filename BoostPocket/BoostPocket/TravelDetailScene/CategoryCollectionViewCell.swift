//
//  CategoryCollectionViewCell.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/07.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CategoryCollectionViewCell"
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    func configure(with category: HistoryCategory) {
        self.categoryImage.image = UIImage(named: category.imageName)
        self.categoryNameLabel.text = category.name
    }
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if newValue {
                self.categoryNameLabel.textColor = .black
            } else {
                self.categoryNameLabel.textColor = .lightGray
            }
        }
    }
    
}
