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
    var exchangeRate: Double
}

class AddHistoryViewController: UIViewController {
    static let identifier = "AddHistoryViewController"
    
    var saveButtonHandler: ((HistoryItemViewModel) -> Void)?
    var baseData: BaseDataForAddingHistory?
    
    @IBOutlet weak var headerView: UIView!
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
        headerView.backgroundColor = baseData.isIncome ? .systemGreen : UIColor(named: "DeleteButtonColor")
        historyTypeLabel.text = baseData.isIncome ? "수입" : "지출"
        flagImageView.image = UIImage(data: baseData.flagImage)
        currencyCodeLabel.text = baseData.currencyCode
        calculatorExpressionLabel.text = ""
        calculatedAmountLabel.text = "0"
        currencyConvertedAmountLabel.text = "KRW"
        
        let dateLabelText = Date().convertToString(format: .dotted)
        dateLabel.text = dateLabelText
    }
    
    private func changeCalculatedAmountLabel() {
        // TODO: - NSExpression Invalid 에러 핸들링
        guard let stringWithMathematicalOperation = calculatorExpressionLabel.text else { return }
        let exp: NSExpression = NSExpression(format: stringWithMathematicalOperation)
        if let amount = exp.expressionValue(with: nil, context: nil) as? Double, let exchangeRate = baseData?.exchangeRate {

            // let roundedAmount = String(format: "%.2f", amount)
            calculatedAmountLabel.text = "\(amount.insertComma)"
            
            let convertedAmount = amount / exchangeRate
            // let roundedConvertedAmount = String(format: "%.3f", convertedAmount)
            currencyConvertedAmountLabel.text = "KRW " + convertedAmount.insertComma
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // saveButtonHandler?()
        // amount, date, image?, title?, memo?
    }
    
}

// MARK: - Calculator IBActions

extension AddHistoryViewController {
    
    @IBAction func btnNumber(sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else { return }
        
        if buttonText == ".", let lastCharacter = calculatorExpressionLabel.text?.last, lastCharacter.isOperation() {
            calculatorExpressionLabel.text?.removeLast()
        }
        
        calculatorExpressionLabel.text! += buttonText
        
        if buttonText != "." {
            changeCalculatedAmountLabel()
        }
    }
    
    @IBAction func btnOperator(sender: UIButton) {
        let buttonText = sender.titleLabel?.text
        
        if let lastCharacter = calculatorExpressionLabel.text?.last, lastCharacter.isOperation() {
            calculatorExpressionLabel.text?.removeLast()
        }
        
        calculatorExpressionLabel.text! += buttonText!
    }
    
    @IBAction func backTapped(_ sender: Any) {
        guard let length = calculatorExpressionLabel.text?.count, length > 0 else { return }
        calculatorExpressionLabel.text?.removeLast()
        
        if let lastCharacter = calculatorExpressionLabel.text?.last,
            !lastCharacter.isOperation() {
            changeCalculatedAmountLabel()
        } else if calculatorExpressionLabel.text?.count == 0 {
            calculatedAmountLabel.text = "0"
            currencyConvertedAmountLabel.text = "KRW"
        }
    }
    
}

extension Character {
    
    func isOperation() -> Bool {
        return self == "+" || self == "-" || self == "*" || self == "/" || self == "."
    }
    
}
