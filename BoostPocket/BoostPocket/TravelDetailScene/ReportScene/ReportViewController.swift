//
//  ReportViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/08.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    weak var travelItemViewModel: HistoryListPresentable?
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var reportPieChartView: ReportPieChartView!
    @IBOutlet weak var totalExpenseKRWLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    @IBOutlet weak var expensesStackView: UIStackView!
    @IBOutlet weak var informationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reportPieChartView.superView.layer.sublayers = nil
        reportPieChartView.removeAllLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reportPieChartView.slices = setupSlices()
        reportPieChartView.animateChart()
        configureLabels()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureStackView()
    }
    
    private func configureLabels() {
        guard let travelItemViewModel = self.travelItemViewModel,
              let identifier = travelItemViewModel.countryIdentifier else { return }
        
        flagImageView.image = UIImage(data: travelItemViewModel.flagImage ?? Data())
        currencyCodeLabel.text = travelItemViewModel.currencyCode
        let totalAmount = travelItemViewModel.getTotalExpense()
        let totalAmountKRW = totalAmount/travelItemViewModel.exchangeRate
        
        totalExpenseKRWLabel.text = "KRW ₩ \(totalAmountKRW.getCurrencyFormat(identifier: "ko_KR"))"
        totalExpenseLabel.text = identifier.currencySymbol + " " + totalAmount.getCurrencyFormat(identifier: identifier)
        
        if totalAmount > 0 {
            informationView.isHidden = false
            reportPieChartView.isHidden = false
            
            let mostFrequentItem = travelItemViewModel.getMostSpentCategory
            let categoryString = mostFrequentItem.0.name
            let percentageString = String(format: "%.1f%%", mostFrequentItem.1)
            let message = categoryString + "에 가장 많은 소비를 했습니다.\n총 지출 금액의 " + percentageString + "를 차지합니다"
            let attributedString = NSMutableAttributedString(string: message)
            let fontSize = UIFont.boldSystemFont(ofSize: 25)
            
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: mostFrequentItem.0.imageName + "-color") ?? UIColor.systemBlue, range: (message as NSString).range(of: categoryString))
            
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "mainColor") ?? UIColor.systemBlue, range: (message as NSString).range(of: percentageString))
            
            attributedString.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String), value: fontSize, range: (message as NSString).range(of: categoryString))
            attributedString.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String), value: fontSize, range: (message as NSString).range(of: percentageString))
            
            summaryLabel.attributedText = attributedString
        } else {
            summaryLabel.text = "지출 내역이 없습니다."
            informationView.isHidden = true
            reportPieChartView.isHidden = true
        }
    }
    
    private func configureStackView() {
        expensesStackView.removeAllArrangedSubviews()
        
        guard let travelItemViewModel = travelItemViewModel,
              let identifier = travelItemViewModel.countryIdentifier else { return }
        
        let expenses = travelItemViewModel.histories.filter({ !$0.isIncome })
        let amounts = travelItemViewModel.getHistoriesDictionary(from: expenses)
        let currencyCode = travelItemViewModel.currencyCode
        let totalAmounts = travelItemViewModel.getTotalExpense()
        let exchangeRate = travelItemViewModel.exchangeRate
        
        let sortedAmounts = amounts.sorted { $0.1 > $1.1 }
        
        sortedAmounts.forEach { (category, amount) in
            if let expenseElementView = Bundle.main.loadNibNamed(ExpenseElementView.identifier, owner: nil, options: nil)?.first as? ExpenseElementView {
                
                let percentage = round((amount / totalAmounts) * 1000 / 10)
                let expenseString = identifier.currencySymbol + " " + amount.getCurrencyFormat(identifier: identifier)
                let amountKRW = amount / exchangeRate
                let expenseKRWString = "₩ " + amountKRW.getCurrencyFormat(identifier: "ko_KR")
                let elementViewModel = ExpenseElementViewModel(category: category,
                                                               categoryPercentage: percentage,
                                                               currencyCode: currencyCode ?? "",
                                                               expense: expenseString,
                                                               expenseKRW: expenseKRWString)
                
                expensesStackView.addArrangedSubview(expenseElementView)
                expenseElementView.frame.size.width = expensesStackView.frame.width
                expenseElementView.heightAnchor.constraint(equalTo: expensesStackView.widthAnchor, multiplier: 0.25).isActive = true
                expenseElementView.configure(with: elementViewModel)
            }
        }
    }
    
    private func setupSlices() -> [Slice] {
        guard let expenses = travelItemViewModel?.histories.filter({ !$0.isIncome }),
              let amounts = travelItemViewModel?.getHistoriesDictionary(from: expenses),
              let totalAmount = travelItemViewModel?.getTotalExpense()
        else { return [] }
        
        let sortedAmounts = amounts.sorted { $0.1 > $1.1 }
        var slices: [Slice] = []
        
        sortedAmounts.forEach { (category, amount) in
            var percentage: CGFloat
            if amount.isNaN || amount.isInfinite {
                percentage = 1
            } else {
                percentage = CGFloat(amount / totalAmount)
            }
            slices.append(Slice(category: category, percent: percentage))
        }
        
        return slices
    }
}
