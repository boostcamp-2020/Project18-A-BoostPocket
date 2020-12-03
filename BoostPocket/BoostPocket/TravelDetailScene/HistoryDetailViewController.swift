//
//  HistoryDetailViewController.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var exchangedMoneyLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var expanseStackView: UIStackView!
    @IBOutlet weak var incomeStackView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    var historyItemVieModel: HistoryItemPresentable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func initDetailView(history: HistoryItemViewModel) {
        
        expanseStackView.translatesAutoresizingMaskIntoConstraints = false
        incomeStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        historyItemVieModel = history
        let trueState = history.isIncome
        expanseStackView.isHidden = trueState
        incomeStackView.isHidden = !trueState
        buttonStackView.topAnchor.constraint(equalTo: expanseStackView.bottomAnchor, constant: 70).isActive = !trueState
        buttonStackView.topAnchor.constraint(equalTo: incomeStackView.bottomAnchor, constant: 70).isActive = trueState
        
        setAttributes()
    }
    
    private func setAttributes() {
        guard let history = historyItemVieModel else { return }
        categoryImageView.image = UIImage(named: history.category.name)
        amountLabel.text = "US$ \(history.amount)"
        titleLabel.text = history.title
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
