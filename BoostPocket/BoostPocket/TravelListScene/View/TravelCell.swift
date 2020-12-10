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
        
        travelTitleLabel.text = travel.title
        configureCoverImage(coverImage: coverImage)
        configureDate(startDate: travel.startDate, endDate: travel.endDate)
        flagImageView.image = UIImage(data: flagImage)
        
        let totalExpenseKRW = travel.getTotalExpense() / travel.exchangeRate
        let totalExpenseKRWString = totalExpenseKRW.getCurrencyFormat(identifier: "ko_KR")
        spentMoneyLabel.text = "₩ " + totalExpenseKRWString
    }
    
    private func configureCoverImage(coverImage: Data) {
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.image = UIImage(data: coverImage)
    }
    
    private func configureDate(startDate: Date?, endDate: Date?) {
        if let startDate = startDate, let endDate = endDate {
            travelingDateLabel.text = startDate.convertToString(format: .dotted) + " ~ " + endDate.convertToString(format: .dotted)
        } else { travelingDateLabel.text = "" }
    }
    
    static func getNib() -> UINib {
        return UINib(nibName: TravelCell.identifier, bundle: nil)
    }
}
