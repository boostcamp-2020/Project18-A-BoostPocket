//
//  ViewController.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TravelListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func newTravelButtonTapped(_ sender: Any) {
        let countryListVC = CountryListViewController.init(nibName: "CountryListViewController", bundle: nil)
        countryListVC.doneButtonHandler = {
            // 컬렉션뷰 reload
            let storyboard = UIStoryboard(name: "TravelDetail", bundle: nil)
            guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else { return }
            self.navigationController?.pushViewController(tabBarVC, animated: true)
        }
        let navigationController = UINavigationController(rootViewController: countryListVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
}

