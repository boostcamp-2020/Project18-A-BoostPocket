//
//  AddHistoryViewController.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class AddHistoryViewController: UIViewController {
    static let identifier = "AddHistoryViewController"
    
    var saveButtonHandler: ((HistoryItemViewModel) -> Void)?
    weak var travelItemViewModel: HistoryListPresentable?
    
    @IBOutlet weak var historyTypeLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var currencyCodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
 
    private func configureViews() {
        flagImageView.image = UIImage(data: travelItemViewModel?.flagImage ?? Data())
        currencyCodeLabel.text = travelItemViewModel?.currencyCode
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // saveButtonHandler?()
    }
    
}

// MARK: - Calculator IBActions

extension AddHistoryViewController {
    
    @IBAction func oneTapped(_ sender: Any) {
    }
    
    @IBAction func twoTapped(_ sender: Any) {
    }
    
    @IBAction func threeTapped(_ sender: Any) {
    }
    
    @IBAction func fourTapped(_ sender: Any) {
    }
    
    @IBAction func fiveTapped(_ sender: Any) {
    }
    
    @IBAction func sixTapped(_ sender: Any) {
    }
    
    @IBAction func sevenTapped(_ sender: Any) {
    }
    
    @IBAction func eightTapped(_ sender: Any) {
    }
    
    @IBAction func nineTapped(_ sender: Any) {
    }
    
    @IBAction func zeroTapped(_ sender: Any) {
    }
    
    @IBAction func dotTapped(_ sender: Any) {
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
