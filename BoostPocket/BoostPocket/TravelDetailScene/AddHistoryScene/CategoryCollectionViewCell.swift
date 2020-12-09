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
    
    func configure(with category: HistoryCategory, isSelected: Bool) {
        self.categoryNameLabel.text = category.name
        
        if isSelected {
            self.categoryImage.image = UIImage(named: category.imageName + "-selected")
            self.categoryNameLabel.textColor = UIColor(named: "basicBlackTextColor")
        } else {
            self.categoryImage.image = UIImage(named: category.imageName)
            self.categoryNameLabel.textColor = UIColor(named: "basicGrayTextColor")
        }
    }
    
}
