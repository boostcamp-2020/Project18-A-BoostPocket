//
//  HistoryDetailViewController.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    
    @IBOutlet weak var historyDateLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var exchangedMoneyLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // Expense
    @IBOutlet weak var historyImageView: UIImageView!
    @IBOutlet weak var expanseMemoLabel: UILabel!
    @IBOutlet weak var isPrepareImageView: UIImageView!
    
    // Income
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var incomeMemoLabel: UILabel!

    @IBOutlet weak var expanseStackView: UIStackView!
    @IBOutlet weak var incomeStackView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    private var imagePicker = UIImagePickerController()
    
    var baseHistoryViewModel: BaseHistoryViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        let isPrepareTap = UITapGestureRecognizer(target: self, action: #selector(isPrepareTapped))
        let historyImageTap = UITapGestureRecognizer(target: self, action: #selector(historyImageTapped))
        isPrepareImageView.addGestureRecognizer(isPrepareTap)
        historyImageView.addGestureRecognizer(historyImageTap)
    }
    
    @objc func titleLabelTapped() {
        
    }
    
    @objc func historyImageTapped() {
        openPhotoLibrary()
    }
    
    @objc func isPrepareTapped() {
        
        guard let history = baseHistoryViewModel, let isPrepare = history.isPrepare else { return }
    
        if isPrepare {
            isPrepareImageView.image = UIImage(named: "isPrepareTrue")
        } else {
            isPrepareImageView.image = UIImage(named: "isPrepareFalse")
        }
        
        baseHistoryViewModel?.isPrepare = !isPrepare
        // TO-DO : 값 업데이트
    }
    
    func configureViews(history: BaseHistoryViewModel) {
        
        expanseStackView.translatesAutoresizingMaskIntoConstraints = false
        incomeStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        baseHistoryViewModel = history
        
        let trueState = history.isIncome
        expanseStackView.isHidden = trueState
        incomeStackView.isHidden = !trueState
        buttonStackView.topAnchor.constraint(equalTo: expanseStackView.bottomAnchor, constant: 70).isActive = !trueState
        buttonStackView.topAnchor.constraint(equalTo: incomeStackView.bottomAnchor, constant: 70).isActive = trueState
        
        setAttributes()
    }
    
    private func setAttributes() {
        guard let history = baseHistoryViewModel else { return }
        
        // 공통
        historyDateLabel.text = history.currentDate.convertToString(format: .fullKoreanDated)
        // TO-DO : 환율 적용된 금액
        if let category = history.category, let title = history.title, let amount = history.amount {
            amountLabel.text = "\(history.currencyCode.getSymbolForCurrencyCode()) \(amount.getCurrencyFormat(currencyCode: history.currencyCode))"
            categoryImageView.image = UIImage(named: category.imageName)
            titleLabel.text = title.isEmpty ? category.name : title
        }
        
        // 지출
        if !history.isIncome {
            amountLabel.textColor = UIColor(named: "deleteButtonColor")
            if let historyImage = history.image, let memo = history.memo, let isPrepare = history.isPrepare {
                historyImageView.image = UIImage(data: historyImage)
                expanseMemoLabel.text = memo
                
                if isPrepare {
                    isPrepareImageView.image = UIImage(named: "isPrepareTrue")
                } else {
                    isPrepareImageView.image = UIImage(named: "isPrepareFalse")
                }
            }
        } else {
            amountLabel.textColor = UIColor(named: "incomeColor")
            currencyCodeLabel.text = history.currencyCode
            // exchangeRateLabel
            if let memo = history.memo {
                incomeMemoLabel.text = memo
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
    }
}

extension HistoryDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            historyImageView.image = newImage
            
            // TO-DO : update
        }
        dismiss(animated: true, completion: nil)
    }
}
