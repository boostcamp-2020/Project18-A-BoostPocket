//
//  HistoryDetailViewController.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    
    static let identifier = "HistoryDetailViewController"
    
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
        
        configureViews()
    }
    
    private func configureViews() {
        imagePicker.delegate = self
        
        let isPrepareTap = UITapGestureRecognizer(target: self, action: #selector(isPrepareTapped))
        let historyImageTap = UITapGestureRecognizer(target: self, action: #selector(historyImageTapped))
        
        isPrepareImageView.addGestureRecognizer(isPrepareTap)
        historyImageView.addGestureRecognizer(historyImageTap)
        
        guard let history = baseHistoryViewModel else { return }
        configureContraints(history: history)
        configureAttributes(history: history)
    }
    
    private func configureContraints(history: BaseHistoryViewModel) {
        expanseStackView.translatesAutoresizingMaskIntoConstraints = false
        incomeStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let trueState = history.isIncome
        expanseStackView.isHidden = trueState
        incomeStackView.isHidden = !trueState
        buttonStackView.topAnchor.constraint(equalTo: expanseStackView.bottomAnchor, constant: 70).isActive = !trueState
        buttonStackView.topAnchor.constraint(equalTo: incomeStackView.bottomAnchor, constant: 70).isActive = trueState
    }
    
    private func configureAttributes(history: BaseHistoryViewModel) {
        // 공통
        historyDateLabel.text = history.currentDate.convertToString(format: .fullKoreanDated)
        if let category = history.category, let title = history.title, let amount = history.amount, let indentifier = history.countryIdentifier {
            amountLabel.text = "\(indentifier.currencySymbol) \(amount.getCurrencyFormat(indentifier: indentifier))"
            exchangedMoneyLabel.text = "KRW \((amount / history.exchangeRate).getCurrencyFormat(indentifier: indentifier))"
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
        // 수입
        } else {
            amountLabel.textColor = UIColor(named: "incomeColor")
            currencyCodeLabel.text = history.currencyCode
            let exchangedKoreanCurrency = 1.00 / history.exchangeRate
            exchangeRateLabel.text = "\(history.currencyCode) 1.00 = KRW \(exchangedKoreanCurrency.getCurrencyFormat(indentifier: "ko_KR"))"
            if let memo = history.memo {
                incomeMemoLabel.text = memo
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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

extension HistoryDetailViewController {
    
    static let storyboardName = "TravelDetail"
    
    static func present(at viewController: UIViewController,
                        historyViewModel: BaseHistoryViewModel) {
        
        let storyBoard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        guard let vc = storyBoard.instantiateViewController(withIdentifier: HistoryDetailViewController.identifier) as? HistoryDetailViewController else { return }
        
        vc.baseHistoryViewModel = historyViewModel
        viewController.present(vc, animated: true, completion: nil)
    }
    
}
