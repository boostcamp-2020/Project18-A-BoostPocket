//
//  AddHistoryViewController.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

struct BaseDataForAddingHistory {
    var isIncome: Bool
    var flagImage: Data
    var currencyCode: String
}

class AddHistoryViewController: UIViewController {
    static let identifier = "AddHistoryViewController"
    
    var saveButtonHandler: ((HistoryItemViewModel) -> Void)?
    var baseData: BaseDataForAddingHistory?
    // weak var travelItemViewModel: HistoryListPresentable?
    
    @IBOutlet weak var historyTypeLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calculatorExpressionLabel: UILabel!
    @IBOutlet weak var calculatedAmountLabel: UILabel!
    @IBOutlet weak var currencyConvertedAmountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
 
    private func configureViews() {
        guard let baseData = baseData else { return }
        historyTypeLabel.text = baseData.isIncome ? "수입" : "지출"
        flagImageView.image = UIImage(data: baseData.flagImage)
        currencyCodeLabel.text = baseData.currencyCode
        calculatorExpressionLabel.text = ""
        calculatedAmountLabel.text = "0"
        currencyConvertedAmountLabel.text = "KRW "
        
        let dateLabelText = Date().convertToString(format: .dotted)
        dateLabel.text = dateLabelText
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // saveButtonHandler?()
    }
    
}

// MARK: - Calculator IBActions

extension AddHistoryViewController {
    
    @IBAction func btnNumber(sender: UIButton) {
        let buttonText = sender.titleLabel?.text
        calculatorExpressionLabel.text = calculatorExpressionLabel.text! + buttonText!
    }
    
    @IBAction func backTapped(_ sender: Any) {
        
    }
    
    @IBAction func divisionTapped(_ sender: Any) {
        
    }
    
    @IBAction func multiplyTapped(_ sender: Any) {
        
    }
    
    @IBAction func additionTapped(_ sender: Any) {
        
    }
    
    @IBAction func subtractionTapped(_ sender: Any) {
        
    }
    
}
