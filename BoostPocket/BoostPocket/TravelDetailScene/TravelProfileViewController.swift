//
//  TravelProfileViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

protocol TravelProfileDelegate: AnyObject {
    func deleteTravel(id: UUID?)
    func updateTravel(id: UUID?, newTitle: String?, newMemo: String?, newStartDate: Date?, newEndDate: Date?, newCoverImage: Data?, newBudget: Double?, newExchangeRate: Double?)
}

class TravelProfileViewController: UIViewController {
    // TODO: - private으로 감추고 주입하는 방법 생각해보기
    var travelItemViewModel: TravelItemPresentable?
    weak var profileDelegate: TravelProfileDelegate?
    
    @IBOutlet weak var travelMemoLabel: UILabel!
    @IBOutlet weak var travelTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        let memoTap = UITapGestureRecognizer(target: self, action: #selector(memoLabelTapped))
        
        travelTitleLabel.addGestureRecognizer(titleTap)
        travelMemoLabel.addGestureRecognizer(memoTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.travelTitleLabel.text = travelItemViewModel?.title
        self.travelMemoLabel.text = travelItemViewModel?.memo ?? "여행을 위한 메모를 입력해보세요"
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        profileDelegate?.deleteTravel(id: travelItemViewModel?.id)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func titleLabelTapped() {
        let storyboard = UIStoryboard.init(name: "TravelDetail", bundle: nil)
        guard let titleEditVC = storyboard.instantiateViewController(withIdentifier: "TitleEditViewController") as? TitleEditViewController else { return }
        
        titleEditVC.saveButtonHandler = { newTitle in
            self.travelTitleLabel.text = newTitle
        }
        titleEditVC.modalPresentationStyle = .overFullScreen
        titleEditVC.modalTransitionStyle = .crossDissolve
        present(titleEditVC, animated: true, completion: nil)
    }
    
    @objc func memoLabelTapped() {
        MemoEditViewController.present(at: self, previousMemo: travelMemoLabel.text ?? "") { [weak self] (newMemo) in
            self?.travelMemoLabel.text = newMemo.isEmpty ? "여행을 위한 메모를 입력해보세요" : newMemo
            self?.profileDelegate?.updateTravel(id: self?.travelItemViewModel?.id, newTitle: nil, newMemo: newMemo, newStartDate: nil, newEndDate: nil, newCoverImage: nil, newBudget: nil, newExchangeRate: nil)
        }
    }
}
