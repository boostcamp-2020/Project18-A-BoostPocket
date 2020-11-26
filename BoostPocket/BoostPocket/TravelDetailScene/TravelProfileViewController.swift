//
//  TravelProfileViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

protocol TravelItemProfileDelegate: AnyObject {
    func deleteTravel(id: UUID?)
}

class TravelProfileViewController: UIViewController {
    // TODO: - private으로 감추고 주입하는 방법 생각해보기
    var travelItemViewModel: TravelItemPresentable?
    weak var profileDelegate: TravelItemProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        profileDelegate?.deleteTravel(id: travelItemViewModel?.id)
        self.navigationController?.popViewController(animated: true)
    }
}
