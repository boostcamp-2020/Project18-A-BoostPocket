//
//  TitleEditViewController.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/30.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TitleEditViewController: UIViewController {

    var saveButtonHandler: ((String) -> Void)?
    
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.saveButtonHandler?(self?.titleTextField.text ?? "")
        }
    }

}
