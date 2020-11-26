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
            setConstraintOfCurrentLabel()
            let message = "지금까지 \(numberOfTravel)개 나라를 여행 했습니다"
            let attributedString = NSMutableAttributedString(string: message)
            // TODO: Asset 메인컬러 가져오기
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: (message as NSString).range(of: "\(numberOfTravel)"))
            headerLabel.attributedText = attributedString
        case .past:
            setConstraintOfDefaultLabel()
            headerLabel.text = "지난 여행"
        case .upcoming:
            setConstraintOfDefaultLabel()
            headerLabel.text = "다가오는 여행"
        }
    }
    
    func setConstraintOfCurrentLabel() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = false
    }
    
    func setConstraintOfDefaultLabel() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = false
        headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
    }
    
    static func getNib() -> UINib {
        return UINib(nibName: TravelHeaderCell.identifier, bundle: nil)
    }
}
