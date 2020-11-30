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
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
            self?.saveButtonHandler?(self?.titleTextField.text ?? "")
        }
    }
}

extension TitleEditViewController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.titleView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height / 3)
            })
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.titleView.transform = .identity
        })
        
    }
}
