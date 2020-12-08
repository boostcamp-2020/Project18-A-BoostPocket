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
        travelItemViewModel?.didFetch = { [weak self] _ in
            self?.reportPieChartView.slices = self?.setupSlices()
//            self?.reportPieChartView.animateChart()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reportPieChartView.animateChart()
    }
    
    private func setupSlices() -> [Slice] {
        guard let histories = travelItemViewModel?.histories.filter({ !$0.isIncome }) else { return [] }
        let standardPercent = CGFloat(1.0/Double(histories.count))

        var slices: [Slice] = []
        histories.forEach { history in
            if let slice = slices.filter({ $0.category == history.category }).first {
                slice.percent += standardPercent
            } else {
                slices.append(Slice(category: history.category, percent: standardPercent))
            }
        }
        return slices
    }
}
