//
//  TitleEditViewController.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/30.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TitleEditViewController: UIViewController {
    static let identifier = "TitleEditViewController"
    
    var saveButtonHandler: ((String) -> Void)?
    private var previousTitle: String?
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextField.text = previousTitle
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.saveButtonHandler?(self?.titleTextField.text ?? "")
        }
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension TitleEditViewController {
    
    static let storyboardName = "TravelDetail"
    
    static func present(at viewController: UIViewController,
                        previousTitle: String,
                        onDismiss: ((String) -> Void)?) {
                
        let storyBoard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        guard let vc = storyBoard.instantiateViewController(withIdentifier: TitleEditViewController.identifier) as? TitleEditViewController else { return }

        vc.previousTitle = previousTitle
        vc.saveButtonHandler = onDismiss
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc, animated: true, completion: nil)
    }
    
}
