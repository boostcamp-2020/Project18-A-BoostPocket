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
    @IBOutlet weak var coverImage: UIImageView!
    
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        let memoTap = UITapGestureRecognizer(target: self, action: #selector(memoLabelTapped))
        let coverImageTap = UITapGestureRecognizer(target: self, action: #selector(coverImageTapped))
        
        travelTitleLabel.addGestureRecognizer(titleTap)
        travelMemoLabel.addGestureRecognizer(memoTap)
        coverImage.addGestureRecognizer(coverImageTap)
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
        self.coverImage.image = UIImage(data: travelItemViewModel?.coverImage ?? Data())
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        profileDelegate?.deleteTravel(id: travelItemViewModel?.id)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func titleLabelTapped() {
        
        TitleEditViewController.present(at: self, previousTitle: travelTitleLabel.text ?? "") { [weak self] (newTitle) in
            let updatingTitle = newTitle.isEmpty ? self?.travelItemViewModel?.countryName : newTitle
            self?.travelTitleLabel.text = updatingTitle
            self?.profileDelegate?.updateTravel(id: self?.travelItemViewModel?.id, newTitle: updatingTitle, newMemo: nil, newStartDate: nil, newEndDate: nil, newCoverImage: nil, newBudget: nil, newExchangeRate: nil)
        }
    }
    
    @objc func memoLabelTapped() {
        MemoEditViewController.present(at: self, previousMemo: travelMemoLabel.text ?? "") { [weak self] (newMemo) in
            self?.travelMemoLabel.text = newMemo.isEmpty ? "여행을 위한 메모를 입력해보세요" : newMemo
            self?.profileDelegate?.updateTravel(id: self?.travelItemViewModel?.id, newTitle: nil, newMemo: newMemo, newStartDate: nil, newEndDate: nil, newCoverImage: nil, newBudget: nil, newExchangeRate: nil)
        }
    }
    
    @objc func coverImageTapped() {
        openPhotoLibrary()
    }
    
    private func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
    }
}

extension TravelProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
