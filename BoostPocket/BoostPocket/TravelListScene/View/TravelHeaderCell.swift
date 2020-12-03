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
    }
    
    func configure(with sectionType: TravelSection, numberOfTravel: Int = 0) {
        switch sectionType {
        case .current:
            let message = "지금까지 \(numberOfTravel)개 나라를 여행 했습니다"
            let attributedString = NSMutableAttributedString(string: message)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "mainColor") ?? UIColor.systemBlue, range: (message as NSString).range(of: "\(numberOfTravel)"))
            headerLabel.attributedText = attributedString
        case .past:
            headerLabel.text = "지난 여행"
        case .upcoming:
            headerLabel.text = "다가오는 여행"
        }
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
