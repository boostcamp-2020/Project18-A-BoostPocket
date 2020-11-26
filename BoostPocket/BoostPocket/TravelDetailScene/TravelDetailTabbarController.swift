//
//  TravelDetailTabbarController.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/26.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TravelDetailTabbarController: UITabBarController {
    static let identifier = "TravelDetailTabbarController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupChildViewControllers(with travelItemViewModel: TravelItemViewModel) {
        guard let profileVC = self.viewControllers?[0] as? TravelProfileViewController else { return }
        profileVC.travelItemViewModel = travelItemViewModel
    }
}
