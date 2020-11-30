//
//  MemoEditViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/30.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class MemoEditViewController: UIViewController {
    
    var saveButtonHandler: ((String) -> Void)?
    
    @IBOutlet weak var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.saveButtonHandler?(self?.memoTextView.text ?? "")
        }
    }
}
