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
    
    private weak var travelItemViewModel: TravelItemPresentable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.delegate = self
        self.navigationItem.title = travelItemViewModel?.title
    }
    
    func setupChildViewControllers(with travelItemViewModel: TravelItemViewModel) {
        self.travelItemViewModel = travelItemViewModel
        
        guard let profileVC = self.viewControllers?[0] as? TravelProfileViewController,
              let historyListVC = self.viewControllers?[1] as? HistoryListViewController,
              let reportVC = self.viewControllers?[2] as? ReportViewController else { return }
        profileVC.travelItemViewModel = travelItemViewModel
        historyListVC.travelItemViewModel = travelItemViewModel
        reportVC.travelItemViewModel = travelItemViewModel
    }
}

extension TravelDetailTabbarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is HistoryListViewController {
            if travelItemViewModel?.startDate == nil || travelItemViewModel?.endDate == nil {
                let alert = UIAlertController(title: "", message: "여행 시작일과 종료일을 설정해주세요!", preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "확인", style: .destructive) { _ in
                    self.selectedIndex = 0
                }
                
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension TravelDetailTabbarController {
    static let storyboardName = "TravelDetail"
    
    static func createTabbarVC() -> TravelDetailTabbarController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? TravelDetailTabbarController
        
        return vc
    }
}
