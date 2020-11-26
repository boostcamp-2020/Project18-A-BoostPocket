//
//  TravelCollectionViewCell.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/26.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TravelCell: UICollectionViewCell {
    
    static let identifier = "TravelCell"
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var travelTitleLabel: UILabel!
    @IBOutlet weak var travelingDateLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var spentMoneyLabel: UILabel!
    
    func configure(with travel: TravelItemViewModel) {
        
        guard let coverImage = travel.coverImage, let flagImage = travel.flagImage else { return }
        
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.image = UIImage(data: coverImage)
        travelTitleLabel.text = travel.title

        if let startDate = travel.startDate, let endDate = travel.endDate {
            travelingDateLabel.text = startDate.convertToString(format: .dotted) + " ~ " + endDate.convertToString(format: .dotted)
        } else { travelingDateLabel.text = "" }
         
        flagImageView.image = UIImage(data: flagImage)
        // TODO : 총 사용 금액으로 설정하기
        spentMoneyLabel.text = "₩ \(Int(travel.budget))"
        spentMoneyLabel.layer.borderWidth = 1
        spentMoneyLabel.layer.cornerRadius = 15
        spentMoneyLabel.layer.borderColor = UIColor.white.cgColor
    }
    
    static func getNib() -> UINib {
        return UINib(nibName: TravelCell.identifier, bundle: nil)
    }
}
