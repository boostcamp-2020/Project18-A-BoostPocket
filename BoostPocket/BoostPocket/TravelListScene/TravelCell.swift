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
        // TODO : date formmater extension 만들기
        travelingDateLabel.text = setDateFormat(startDate: travel.startDate, endDate: travel.endDate)
        flagImageView.image = UIImage(data: flagImage)
        // TODO : 총 사용 금액으로 설정하기
        spentMoneyLabel.text = "\(travel.budget)"
    }
    
    static func getNib() -> UINib {
        return UINib(nibName: TravelCell.identifier, bundle: nil)
    }

    func setDateFormat(startDate: Date?, endDate: Date?) -> String {
        var dateString = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd."
        if let startDate = startDate, let endDate = endDate {
            dateString += formatter.string(from: startDate)
            dateString += " ~ "
            dateString += formatter.string(from: endDate)
        }
        return dateString
    }
    
}
