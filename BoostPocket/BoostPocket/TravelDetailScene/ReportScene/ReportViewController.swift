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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        travelItemViewModel?.needFetchItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reportPieChartView.slices = setupSlices()
        reportPieChartView.animateChart()
        configureLabels()
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
        let mostFrequentItem = travelItemViewModel.mostFrequentCategory
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
        
        
    }
    
    private func setupSlices() -> [Slice] {
        guard let histories = travelItemViewModel?.histories.filter({ !$0.isIncome }) else { return [] }
        
        var dictionary: [HistoryCategory: Int] = [:]
        let totalNum = histories.count
        var slices: [Slice] = []
        
        histories.forEach { history in
            if let value = dictionary[history.category] {
                dictionary[history.category] = value + 1
            } else {
                dictionary[history.category] = 1
            }
        }
        
        dictionary.forEach { (key, value) in
            slices.append(Slice(category: key, percent: CGFloat(Float(value) / Float(totalNum))))
        }

        return slices
    }
}
