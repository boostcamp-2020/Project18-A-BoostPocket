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
    private let placeholder = "여행을 위한 메모를 입력해보세요"
    @IBOutlet weak var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTextView.delegate = self
        setInitialTextviewPlaceholder()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.saveButtonHandler?(self?.memoTextView.text ?? "")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setInitialTextviewPlaceholder() {
        self.memoTextView.text = previousMemo
        if previousMemo == placeholder {
            memoTextView.textColor = .lightGray
        }
    }
    
    private func setTextViewPlaceholder() {
        if memoTextView.text == placeholder {
            memoTextView.text = ""
            memoTextView.textColor = .black
        } else if memoTextView.text.isEmpty {
            memoTextView.text = placeholder
            memoTextView.textColor = .lightGray
        }
    }
}

extension MemoEditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        setTextViewPlaceholder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setTextViewPlaceholder()
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
