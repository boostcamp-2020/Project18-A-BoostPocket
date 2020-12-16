//
//  MemoEditViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/30.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

enum EditMemoType: String {
    case travelMemo = "여행을 위한 메모를 입력해보세요"
    case expenseMemo = "지출에 대한 메모를 입력해보세요"
    case incomeMemo = "수입에 대한 메모를 입력해보세요"
}

class MemoEditViewController: UIViewController {
    static let identifier = "MemoEditViewController"
    
    private var saveButtonHandler: ((String) -> Void)?
    private var memo: String?
    private var memoType: EditMemoType?
    @IBOutlet weak var memoView: UIView!
    @IBOutlet weak var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTextView.delegate = self
        setInitialTextviewPlaceholder()
        memoTextView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unregisterForKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.saveButtonHandler?(self?.memo ?? "")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setInitialTextviewPlaceholder() {
        if let previousMemo = memo, !previousMemo.isEmpty {
            // 기존의 메모가 nil이 아니고 빈 문자열이 아닐 때
            memoTextView.text = previousMemo
            memoTextView.textColor = UIColor(named: "basicBlackTextColor")
        } else {
            // 기존의 메모가 없을 때 (Nil)
            memoTextView.text = memoType?.rawValue
            memoTextView.textColor = UIColor(named: "basicGrayTextColor")
        }
    }
    
    private func setTextViewPlaceholder() {
        if memoTextView.text.isPlaceholder() {
            memoTextView.text = ""
            memoTextView.textColor = UIColor(named: "basicBlackTextColor")
        }
    }
}

extension MemoEditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        setTextViewPlaceholder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        memo = textView.text.isPlaceholder() ? "" : textView.text
        if textView.text.isEmpty {
            setTextViewPlaceholder()
        }
    }
}

extension MemoEditViewController {
    
    static let storyboardName = "TravelDetail"
    
    static func present(at viewController: UIViewController,
                        memoType: EditMemoType,
                        previousMemo: String?,
                        onDismiss: ((String) -> Void)?) {
        
        let storyBoard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        guard let vc = storyBoard.instantiateViewController(withIdentifier: MemoEditViewController.identifier) as? MemoEditViewController else { return }
        
        vc.memo = previousMemo
        vc.memoType = memoType
        vc.saveButtonHandler = onDismiss
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc, animated: true, completion: nil)
    }
    
}

extension MemoEditViewController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.memoView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height / 3)
            })
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.memoView.transform = .identity
        })
    }
}
