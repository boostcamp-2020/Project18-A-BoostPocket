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

    @IBOutlet weak var reportPieChartView: ReportPieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        travelItemViewModel?.needFetchItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reportPieChartView.slices = setupSlices()
        reportPieChartView.animateChart()
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
