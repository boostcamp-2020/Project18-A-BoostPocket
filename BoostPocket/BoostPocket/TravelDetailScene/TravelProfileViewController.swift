//
//  TravelProfileViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TravelProfileViewController: UIViewController {
    
    var deleteButtonHandler: (() -> Void)?
    
    // TODO: - private으로 감추고 주입하는 방법 생각해보기
    var travelItemViewModel: TravelItemPresentable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteButtonHandler?()
    }
}
