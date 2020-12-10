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
    
    func configure(with sectionType: TravelSectionCase, numberOfTravel: Int = 0) {
        var attributedString = NSMutableAttributedString()
        switch sectionType {
        case .current:
            attributedString = getAttributedString(of: "지금까지 \(numberOfTravel)개 나라를 여행 했습니다", numberOfTravel: numberOfTravel)
            headerLabel.textAlignment = .center
        case .past:
            attributedString = getAttributedString(of: "지난 여행 \(numberOfTravel)개", numberOfTravel: numberOfTravel)
            headerLabel.textAlignment = .left
        case .upcoming:
            attributedString = getAttributedString(of: "다가오는 여행 \(numberOfTravel)개", numberOfTravel: numberOfTravel)
            headerLabel.textAlignment = .left
        }
        headerLabel.attributedText = attributedString
    }
    
    private func getAttributedString(of message: String, numberOfTravel: Int) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: message)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "mainColor") ?? UIColor.systemBlue, range: (message as NSString).range(of: "\(numberOfTravel)"))
        
        return attributedString
    }

    static func getNib() -> UINib {
        return UINib(nibName: TravelHeaderCell.identifier, bundle: nil)
    }
}
