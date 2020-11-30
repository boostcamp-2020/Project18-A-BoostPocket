//
//  MemoEditViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/30.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class MemoEditViewController: UIViewController {
    static let identifier = "MemoEditViewController"
    
    var saveButtonHandler: ((String) -> Void)?
    private var previousMemo: String?
    @IBOutlet weak var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.memoTextView.text = previousMemo
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.saveButtonHandler?(self?.memoTextView.text ?? "")
        }
    }
}

extension MemoEditViewController {
    
    static let storyboardName = "TravelDetail"
    
    static func present(at viewController: UIViewController,
                        previousMemo: String,
                        onDismiss: ((String) -> Void)?) {
                
        let storyBoard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        guard let vc = storyBoard.instantiateViewController(withIdentifier: MemoEditViewController.identifier) as? MemoEditViewController else { return }

        vc.previousMemo = previousMemo
        vc.saveButtonHandler = onDismiss
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc, animated: true, completion: nil)
    }
    
}
