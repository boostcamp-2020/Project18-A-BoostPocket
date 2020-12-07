//
//  AddHistoryViewController.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/03.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit
import Toaster

protocol AddHistoryDelegate: AnyObject {
    func createHistory(newHistoryData: NewHistoryData)
    func updateHisotry(at historyId: UUID?, newHistoryData: NewHistoryData)
}

struct BaseHistoryViewModel {
    // update, delete 시 필요
    var id: UUID?
    // new, edit 모두 필요한 정보
    var isIncome: Bool
    var flagImage: Data
    var currencyCode: String
    var currentDate: Date
    var exchangeRate: Double
    // edit 시 필요한 정보
    var isCard: Bool?
    var category: HistoryCategory?
    var title: String?
    var memo: String?
    var image: Data?
    var amount: Double?
    // 상세화면
    var isPrepare: Bool?
    var countryIdentifier: String?
}

struct NewHistoryData {
    var isIncome: Bool
    var title: String
    var memo: String?
    var date: Date
    var image: Data?
    var amount: Double
    var category: HistoryCategory
    var isCard: Bool?
    var isPrepare: Bool?
}

class AddHistoryViewController: UIViewController {
    static let identifier = "AddHistoryViewController"
    weak var delegate: AddHistoryDelegate?
    
    private var saveButtonHandler: ((NewHistoryData) -> Void)?
    private var baseHistoryViewModel: BaseHistoryViewModel?
    private var isAddingIncome: Bool = false
    private var historyTitle: String?
    private var memo: String?
    private var date: Date = Date()
    private var image: Data?
    private var amount: Double = 0
    private var category: HistoryCategory = .etc
    private var isCard: Bool = false
    private var imagePicker = UIImagePickerController()
    private let historyTitlePlaceholder = "항목명을 입력해주세요 (선택)"
    private var categories: [HistoryCategory] = [.food, .shopping, .tourism, .transportation, .accommodation, .etc]
    private var isCreate: Bool = true
    
    @IBOutlet weak var historyTitleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var historyTypeLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calculatorExpressionLabel: UILabel!
    @IBOutlet weak var calculatedAmountLabel: UILabel!
    @IBOutlet weak var currencyConvertedAmountLabel: UILabel!
    @IBOutlet var coloredButtons: [UIButton]!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var memoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        configureViews()
    }
    
    private func configureViews() {
        guard let newHistoryViewModel = self.baseHistoryViewModel else { return }
        self.isAddingIncome = newHistoryViewModel.isIncome
        if let _ = newHistoryViewModel.id {
            self.isCreate = false
        }
        
        let color = isAddingIncome ? .systemGreen : UIColor(named: "deleteButtonColor")
        
        segmentedControl.isHidden = isAddingIncome
        imageButton.isHidden = isAddingIncome
        memoButton.isHidden = isAddingIncome
        categoryCollectionView.isHidden = isAddingIncome
        
        // 상단 뷰 색상
        headerView.backgroundColor = color
        
        // 기록 타입
        historyTypeLabel.text = isAddingIncome ? "수입" : "지출"
        historyTypeLabel.textColor = .white
        
        // 국기 이미지
        flagImageView.image = UIImage(data: newHistoryViewModel.flagImage)
        
        // 환율코드
        currencyCodeLabel.text = newHistoryViewModel.currencyCode
        
        // 계산식 레이블, 계산된 금액 레이블, 환율을 적용하여 변환한 금액 레이블
        calculatedAmountLabel.textColor = .white
        if let previousAmount = newHistoryViewModel.amount {
            self.amount = previousAmount
            calculatorExpressionLabel.text = "\(previousAmount)"
            calculatedAmountLabel.text = "\(previousAmount)"
            currencyConvertedAmountLabel.text = "KRW \(previousAmount / newHistoryViewModel.exchangeRate)"
        } else {
            calculatorExpressionLabel.text = ""
            calculatedAmountLabel.text = "0"
            currencyConvertedAmountLabel.text = "KRW"
        }
        
        // 카드/현금 여부
        if let previousIsCard = newHistoryViewModel.isCard, previousIsCard {
            segmentedControl.selectedSegmentIndex = 1
            self.isCard = true
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
        
        // 카테고리 CollectionView
        if !isAddingIncome {
            categoryCollectionView.delegate = self
            categoryCollectionView.dataSource = self
            categoryCollectionView.register(UINib(nibName: CategoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        }
        
        // 항목명
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        historyTitleLabel.addGestureRecognizer(titleTap)
        if let previousTitle = newHistoryViewModel.title {
            self.historyTitle = previousTitle
            historyTitleLabel.text = self.historyTitle
            historyTitleLabel.textColor = .black
        } else {
            historyTitleLabel.text = historyTitlePlaceholder
            historyTitleLabel.textColor = .systemGray2
        }
        
        // 날짜
        // TODO: DatePicker로 변경해서 사용자가 날짜를 바꿀 수 있도록 하는 기능 구현하기
        let dateLabelText = newHistoryViewModel.currentDate.convertToString(format: .dotted)
        dateLabel.text = dateLabelText
        
        // 이미지
        if let previousImage = newHistoryViewModel.image {
            self.image = previousImage
            self.imageButton.tintColor = .black
        }
        
        // 메모
        if let previousMemo = newHistoryViewModel.memo {
            self.memo = previousMemo
            self.memoButton.tintColor = .black
        }
        
        // 계산기 버튼 색상
        coloredButtons.forEach { button in
            button.setTitleColor(color, for: .normal)
            button.tintColor = color
        }
    }
    
    private func changeCalculatedAmountLabel() {
        guard let stringWithMathematicalOperation = calculatorExpressionLabel.text, isValidExpression(stringWithMathematicalOperation) else { return }
        
        let exp: NSExpression = NSExpression(format: stringWithMathematicalOperation)
        if let amount = exp.expressionValue(with: nil, context: nil) as? Double, let exchangeRate = baseHistoryViewModel?.exchangeRate {
            
            calculatedAmountLabel.text = "\(amount.insertComma)"
            
            let convertedAmount = amount / exchangeRate
            currencyConvertedAmountLabel.text = "KRW " + convertedAmount.insertComma
            
            self.amount = amount
        }
    }
    
    private func isValidExpression(_ exp: String) -> Bool {
        let operators = CharacterSet(charactersIn: "+_*/")
        let numbersOnly = exp.components(separatedBy: operators)
        
        for str in numbersOnly {
            let pieces = str.components(separatedBy: ".")
            if pieces.count > 2 {
                print("invalid!")
                return false
            }
        }
        
        return true
    }
    
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.isCard = false
        case 1:
            self.isCard = true
        default:
            break
        }
    }
    
    @objc func titleLabelTapped() {
        let previousTitle = historyTitleLabel.text == historyTitlePlaceholder ? "" : historyTitle
        
        TitleEditViewController.present(at: self, previousTitle: previousTitle ?? "") { [weak self] (newTitle) in
            guard let self = self else { return }
            if self.isAddingIncome {
                self.historyTitle = newTitle.isEmpty ? HistoryCategory.income.name : newTitle
            } else {
                self.historyTitle = newTitle.isEmpty ? HistoryCategory.etc.name : newTitle
            }
            
            self.historyTitleLabel.textColor = self.historyTitle == self.historyTitlePlaceholder ? .systemGray2 : .black
            self.historyTitleLabel.text = self.historyTitle
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        var newHistoryData: NewHistoryData
        
        if isAddingIncome {
            newHistoryData = NewHistoryData(isIncome: true, title: historyTitle ?? HistoryCategory.income.name, memo: memo, date: date, image: nil, amount: amount, category: .income, isCard: nil)
        } else {
            newHistoryData = NewHistoryData(isIncome: false, title: historyTitle ?? HistoryCategory.etc.name, memo: memo, date: date, image: image, amount: amount, category: category, isCard: isCard, isPrepare: baseHistoryViewModel?.isPrepare)
        }
        
        if isCreate {
            delegate?.createHistory(newHistoryData: newHistoryData)
        } else {
            delegate?.updateHisotry(at: baseHistoryViewModel?.id, newHistoryData: newHistoryData)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        openPhotoLibrary()
    }
    
    private func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
    }
    
    @IBAction func addMemoButtonTapped(_ sender: UIButton) {
        MemoEditViewController.present(at: self, memoType: .expenseMemo, previousMemo: memo) { [weak self] newMemo in
            let memoToast = Toast(text: "메모를 입력했습니다", duration: Delay.short)
            memoToast.show()
            
            if newMemo.isEmpty {
                self?.memo = nil
                self?.memoButton.tintColor = .lightGray
            } else {
                self?.memo = newMemo
                self?.memoButton.tintColor = .black
            }
        }
    }
    
}

extension AddHistoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageToast = Toast(text: "사진을 추가했습니다", duration: Delay.short)
            imageToast.show()
            
            self.image = newImage.pngData()
            self.imageButton.tintColor = .black
        }
        
        dismiss(animated: true)
    }
    
}

// MARK: - Calculator IBActions

extension AddHistoryViewController {
    
    @IBAction func btnNumber(sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else { return }
        
        if buttonText == ".", let lastCharacter = calculatorExpressionLabel.text?.last, lastCharacter.isOperation() {
            calculatorExpressionLabel.text?.removeLast()
        }
        
        calculatorExpressionLabel.text! += buttonText
        
        if buttonText != "." {
            changeCalculatedAmountLabel()
        }
    }
    
    @IBAction func btnOperator(sender: UIButton) {
        let buttonText = sender.titleLabel?.text
        
        if let lastCharacter = calculatorExpressionLabel.text?.last, lastCharacter.isOperation() {
            calculatorExpressionLabel.text?.removeLast()
        }
        
        calculatorExpressionLabel.text! += buttonText!
    }
    
    @IBAction func backTapped(_ sender: Any) {
        guard let length = calculatorExpressionLabel.text?.count, length > 0 else { return }
        calculatorExpressionLabel.text?.removeLast()
        
        if let lastCharacter = calculatorExpressionLabel.text?.last,
            !lastCharacter.isOperation() {
            changeCalculatedAmountLabel()
        } else if calculatorExpressionLabel.text?.count == 0 {
            calculatedAmountLabel.text = "0"
            currencyConvertedAmountLabel.text = "KRW"
        }
    }
    
}

extension AddHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: categories[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width * 0.15
        return CGSize(width: width, height: width)
    }
    
}

extension AddHistoryViewController {
    
    static let nibName = "AddHistoryViewController"
    
    static func present(at viewController: UIViewController,
                        newHistoryViewModel: BaseHistoryViewModel,
                        onPresent: @escaping (() -> Void)) {
        
        let vc = AddHistoryViewController(nibName: nibName, bundle: nil)
        if let historyListVC = viewController as? HistoryListViewController {
            vc.delegate = historyListVC
        }
        vc.baseHistoryViewModel = newHistoryViewModel
        viewController.present(vc, animated: true) {
            onPresent()
        }
    }
    
}
