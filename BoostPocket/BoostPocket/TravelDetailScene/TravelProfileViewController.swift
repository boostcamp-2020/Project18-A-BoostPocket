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
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var coverImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        let memoTap = UITapGestureRecognizer(target: self, action: #selector(memoLabelTapped))
        
        travelTitleLabel.addGestureRecognizer(titleTap)
        travelMemoLabel.addGestureRecognizer(memoTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTravelProfile()
    }
    
    private func setupTravelProfile() {
        self.travelTitleLabel.text = travelItemViewModel?.title
        if let memo = travelItemViewModel?.memo, !memo.isEmpty {
            travelMemoLabel.text = memo
        } else {
            travelMemoLabel.text = "여행을 위한 메모를 입력해보세요"
        }
        self.flagImage.image = UIImage(data: travelItemViewModel?.flagImage ?? Data())
        self.startDatePicker.date = travelItemViewModel?.startDate ?? Date()
        self.endDatePicker.date = travelItemViewModel?.endDate ?? Date()
        self.coverImage.image = UIImage(data: travelItemViewModel?.coverImage ?? Data())
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        profileDelegate?.deleteTravel(id: travelItemViewModel?.id)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startDateSelected(_ sender: UIDatePicker) {
        profileDelegate?.updateTravel(id: travelItemViewModel?.id, newTitle: travelItemViewModel?.title, newMemo: travelItemViewModel?.memo, newStartDate: sender.date, newEndDate: travelItemViewModel?.endDate, newCoverImage: travelItemViewModel?.coverImage, newBudget: travelItemViewModel?.budget, newExchangeRate: travelItemViewModel?.exchangeRate)
        endDatePicker.minimumDate = startDatePicker.date
    }
    
    @IBAction func endDateSelected(_ sender: UIDatePicker) {
        profileDelegate?.updateTravel(id: travelItemViewModel?.id, newTitle: travelItemViewModel?.title, newMemo: travelItemViewModel?.memo, newStartDate: travelItemViewModel?.startDate, newEndDate: sender.date, newCoverImage: travelItemViewModel?.coverImage, newBudget: travelItemViewModel?.budget, newExchangeRate: travelItemViewModel?.exchangeRate)
    }
    
    @objc func titleLabelTapped() {
        TitleEditViewController.present(at: self, previousTitle: travelTitleLabel.text ?? "") { [weak self] (newTitle) in
            let updatingTitle = newTitle.isEmpty ? self?.travelItemViewModel?.countryName : newTitle
            self?.travelTitleLabel.text = updatingTitle
            self?.profileDelegate?.updateTravel(id: self?.travelItemViewModel?.id, newTitle: updatingTitle, newMemo: self?.travelItemViewModel?.memo, newStartDate: self?.travelItemViewModel?.startDate, newEndDate: self?.travelItemViewModel?.endDate, newCoverImage: self?.travelItemViewModel?.coverImage, newBudget: self?.travelItemViewModel?.budget, newExchangeRate: self?.travelItemViewModel?.exchangeRate)
        }
    }
    
    @objc func memoLabelTapped() {
        MemoEditViewController.present(at: self, previousMemo: travelMemoLabel.text ?? "") { [weak self] (newMemo) in
            self?.travelMemoLabel.text = newMemo.isEmpty ? "여행을 위한 메모를 입력해보세요" : newMemo
            self?.profileDelegate?.updateTravel(id: self?.travelItemViewModel?.id, newTitle: self?.travelItemViewModel?.title, newMemo: newMemo, newStartDate: self?.travelItemViewModel?.startDate, newEndDate: self?.travelItemViewModel?.endDate, newCoverImage: self?.travelItemViewModel?.coverImage, newBudget: self?.travelItemViewModel?.budget, newExchangeRate: self?.travelItemViewModel?.exchangeRate)
        }
    }
}
