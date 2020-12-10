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
        switch sectionType {
        case .current:
            let attributedString = getAttributedString(of: "지금까지 \(numberOfTravel)개 나라를 여행 했습니다", numberOfTravel: numberOfTravel)
            headerLabel.attributedText = attributedString
        case .past:
            let attributedString = getAttributedString(of: "지난 여행 \(numberOfTravel)개", numberOfTravel: numberOfTravel)
            headerLabel.attributedText = attributedString
        case .upcoming:
            let attributedString = getAttributedString(of: "다가오는 여행 \(numberOfTravel)개", numberOfTravel: numberOfTravel)
            headerLabel.attributedText = attributedString
        }
    }
    
    private func getAttributedString(of message: String, numberOfTravel: Int) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: message)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "mainColor") ?? UIColor.systemBlue, range: (message as NSString).range(of: "\(numberOfTravel)"))
        
        return attributedString
    }
    
    /*
    func setConstraintOfCurrentLabel() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = false
        headerLabel.removeConstraint(headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15))
        headerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    func setConstraintOfDefaultLabel() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // headerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = false
        headerLabel.removeConstraint(headerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
    }
    */
    
    static func getNib() -> UINib {
        return UINib(nibName: TravelHeaderCell.identifier, bundle: nil)
    }
}
