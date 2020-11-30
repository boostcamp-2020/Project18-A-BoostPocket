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
    
    @IBOutlet weak var travelMemoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(memoLabelTapped))
        travelMemoLabel.addGestureRecognizer(tap)
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        profileDelegate?.deleteTravel(id: travelItemViewModel?.id)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func memoLabelTapped() {
        let storyboard = UIStoryboard.init(name: "TravelDetail", bundle: nil)
        let memoEditVC = storyboard.instantiateViewController(withIdentifier: "MemoEditViewController")
        memoEditVC.modalPresentationStyle = .overFullScreen
        memoEditVC.modalTransitionStyle = .crossDissolve
        present(memoEditVC, animated: true, completion: nil)
    }
}
