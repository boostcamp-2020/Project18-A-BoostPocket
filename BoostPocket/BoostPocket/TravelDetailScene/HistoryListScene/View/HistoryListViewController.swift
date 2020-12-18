//
//  HistoryListViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class DataSource: UITableViewDiffableDataSource<HistoryListSectionHeader, HistoryItemViewModel> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

class HistoryListViewController: UIViewController {
    static let identifier = "HistoryListViewController"
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<HistoryListSectionHeader, HistoryItemViewModel>
    
    @IBOutlet weak var historyListTableView: UITableView!
    @IBOutlet weak var dayStackView: UIStackView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var prepareButton: UIButton!
    @IBOutlet weak var moneySegmentedControl: UISegmentedControl!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var addExpenseButton: UIButton!
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var floatingStackView: UIStackView!
    @IBOutlet weak var totalAmountView: TotalAmountView!
    @IBOutlet weak var historyGuideLabel: UILabel!
    
    lazy var buttons = [self.addExpenseButton, self.addIncomeButton]
    weak var presenter: HistoryListVCPresenter?
    weak var travelItemViewModel: HistoryListPresentable?
    private weak var selectedDateButton: UIButton?
    private var historyFilter = HistoryFilter()
    private(set) var isFloatingButtonOpened: Bool = false
    private lazy var dataSource = configureDatasource()
    private lazy var headers = setupSection(with: travelItemViewModel?.histories ?? [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        presenter?.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDays(from: travelItemViewModel?.startDate, to: travelItemViewModel?.endDate)
        configureSelectedDateButton()
        moneySegmentedControl.selectedSegmentIndex = 0
    }
    
    private func configureSelectedDateButton() {
        if let selectedDate = historyFilter.selectedDate,
            let startDate = travelItemViewModel?.startDate,
            let endDate = travelItemViewModel?.endDate {
            if selectedDate.isValidInRange(from: startDate, to: endDate) {
                let index = selectedDate.interval(ofComponent: .day, fromDate: startDate)
                
                guard let selectedDateCell = dayStackView.subviews[index].subviews.filter({ $0 is UIButton }).first as? UIButton else { return }
                
                selectedDateButton = selectedDateCell
            } else {
                isPrepareButtonTapped(allButton)
            } 
        } else {
            isPrepareButtonTapped(allButton)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectedDateButton?.configureSelectedButton()
    }
    
    // MARK: - Configuration
    
    private func configure() {
        allButton.configureSelectedButton()
        configureTravelItemViewModel()
        configureTableView()
        configureSegmentedControl()
        configureFloatingActionButton()
        setTotalAmountView()
        
        let hasHistory = travelItemViewModel?.histories.count != 0 // 기록이 있으면 true
        historyGuideLabel.isHidden = hasHistory
        historyGuideLabel.text = "기록이 없습니다 🙂"
    }
    
    private func configureSegmentedControl() {
        moneySegmentedControl.selectedSegmentTintColor = .clear
        moneySegmentedControl.backgroundColor = .none
        moneySegmentedControl.layer.backgroundColor = UIColor.clear.cgColor
        moneySegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNextCondensed-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        moneySegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNextCondensed-Medium", size: 16)!, NSAttributedString.Key.foregroundColor: UIColor(named: "mainColor") ?? UIColor.systemBlue], for: .selected)
    }
    
    private func configureTableView() {
        historyListTableView.delegate = self
        historyListTableView.dataSource = dataSource
        historyListTableView.register(HistoryCell.getNib(), forCellReuseIdentifier: HistoryCell.identifier)
        historyListTableView.register(HistoryHeaderCell.getNib(), forHeaderFooterViewReuseIdentifier: HistoryHeaderCell.identifier)
    }
    
    private func configureDatasource() -> DataSource {
        let datasource = DataSource(tableView: historyListTableView) { (tableview, indexPath, item) -> UITableViewCell? in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell,
                let identifier = self.travelItemViewModel?.countryIdentifier
                else { return UITableViewCell() }
            
            cell.selectionStyle = .none
            cell.configure(with: item, identifier: identifier)
            return cell
        }
        
        return datasource
    }
    
    private func configureFloatingActionButton() {
        let buttonWidth = self.view.bounds.width * 0.13
        
        floatingButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        floatingButton.layer.cornerRadius = buttonWidth * 0.5
        floatingButton.clipsToBounds = true
        
        addIncomeButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        addIncomeButton.layer.cornerRadius = buttonWidth * 0.5
        addIncomeButton.clipsToBounds = true
        
        addExpenseButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        addExpenseButton.layer.cornerRadius = buttonWidth * 0.5
        addExpenseButton.clipsToBounds = true
    }
    
    private func setTotalAmountView() {
        let filteredHistories = historyFilter.filterHistories(with: travelItemViewModel?.histories)
        let expense = filteredHistories.filter({ !$0.isIncome }).reduce(0) { $0 + $1.amount }
        let income = filteredHistories.filter({ $0.isIncome }).reduce(0) { $0 + $1.amount }
        
        self.totalAmountView.configure(withExpense: expense, income: income, identifier: travelItemViewModel?.countryIdentifier)
    }
    
    private func configureTravelItemViewModel() {
        travelItemViewModel?.didFetch = { [weak self] _ in
            guard let self = self else { return }
            
            let filteredHistory = self.historyFilter.filterHistories(with: self.travelItemViewModel?.histories)
            self.configureHistoryGuideLabel(filteredHistory: filteredHistory)
            self.applySnapshot(with: filteredHistory)
            self.setTotalAmountView()
        }
        
        travelItemViewModel?.needFetchItems()
    }
    
    private func configureHistoryGuideLabel(filteredHistory: [HistoryItemViewModel]) {
        let hasHistory = filteredHistory.count != 0
        self.historyGuideLabel.isHidden = hasHistory
        
        if let selectedDate = self.historyFilter.selectedDate {
            self.historyGuideLabel.text = selectedDate.convertToString(format: .korean) + "에\n기록이 없습니다 🙂"
        } else {
            self.historyGuideLabel.text = "기록이 없습니다 🙂"
        }
    }
    
    // MARK: - Floating Action Button
    
    @IBAction func floatingActionButtonTapped(_ sender: UIButton) {
        presenter?.onFloatingActionButtonTapped()
        
        switch isFloatingButtonOpened {
        case true:
            presenter?.onCloseFloatingActions()
            closeFloatingActions { _ in }
        case false:
            presenter?.onOpenFloatingActions()
            openFloatingActions { _ in }
        }
    }
    
    func closeFloatingActions(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        isFloatingButtonOpened = false
        
        DispatchQueue.main.async { [weak self] in
            self?.rotateFloatingActionButton()
            
            self?.buttons.reversed().forEach { button in
                group.enter()
                UIView.animate(withDuration: 0.3, animations: {
                    button?.isHidden = true
                    self?.view.layoutIfNeeded()
                }, completion: { done in
                    if done {
                        group.leave()
                    }
                })
            }
        }
        
        let result = group.wait(timeout: DispatchTime(uptimeNanoseconds: 1))
        
        switch result {
        case .success:
            presenter?.onCloseFloatingActions()
            completion(true)
        case .timedOut:
            completion(false)
        }
    }
    
    func openFloatingActions(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        isFloatingButtonOpened = true
        
        DispatchQueue.main.async { [weak self] in
            self?.rotateFloatingActionButton()
            
            self?.buttons.forEach { button in
                group.enter()
                button?.isHidden = false
                button?.alpha = 0
                
                UIView.animate(withDuration: 0.3, animations: {
                    button?.alpha = 1
                    self?.view.layoutIfNeeded()
                }, completion: { done in
                    if done {
                        group.leave()
                    }
                })
            }
        }
        
        let result = group.wait(timeout: DispatchTime(uptimeNanoseconds: 1))
        
        switch result {
        case .success:
            presenter?.onOpenFloatingActions()
            completion(true)
        case .timedOut:
            completion(false)
        }
    }
    
    func rotateFloatingActionButton() {
        let roatation = isFloatingButtonOpened ? CGAffineTransform(rotationAngle: .pi - (.pi / 4)) : CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.floatingButton.transform = roatation
        }
        
        presenter?.onRotateFloatingActionButton()
    }
    
    @IBAction func addExpenseButtonTapped(_ sender: UIButton) {
        addNewHistory(isIncome: false)
    }
    
    @IBAction func addIncomeButtonTapped(_ sender: UIButton) {
        addNewHistory(isIncome: true)
    }
    
    private func addNewHistory(isIncome: Bool) {
        let newHistoryViewModel = BaseHistoryViewModel(isIncome: isIncome,
                                                       flagImage: self.travelItemViewModel?.flagImage ?? Data(),
                                                       currencyCode: self.travelItemViewModel?.currencyCode ?? "",
                                                       currentDate: self.historyFilter.selectedDate ?? Date(),
                                                       exchangeRate: self.travelItemViewModel?.exchangeRate ?? 0)
        
        let onPresent: (() -> Void)  = { [weak self] in
            self?.closeFloatingActions { _ in }
        }
        
        AddHistoryViewController.present(at: self,
                                         delegateTarget: self,
                                         baseHistoryViewModel: newHistoryViewModel,
                                         onPresent: onPresent,
                                         onDismiss: nil)
    }
    
    private func applySnapshot(with histories: [HistoryItemViewModel]) {
        var snapshot = Snapshot()
        headers = setupSection(with: histories)
        snapshot.appendSections(headers)
        
        histories.forEach { history in
            if let section = headers.filter({ history.date.isSameDay(with: $0.date) }).first {
                snapshot.appendItems([history], toSection: section)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupSection(with histories: [HistoryItemViewModel]) -> [HistoryListSectionHeader] {
        guard let startDate = travelItemViewModel?.startDate else { return [] }
        var days = Set<HistoryListSectionHeader>()
        histories.forEach { history in
            let day = history.date.interval(ofComponent: .day, fromDate: startDate)
            let amount = history.amount
            let date = history.date
            if let sameDay = days.filter({ date.isSameDay(with: $0.date) }).first {
                sameDay.amount = history.isIncome ? sameDay.amount :  sameDay.amount + amount
            } else {
                days.insert(HistoryListSectionHeader(dayNumber: day + 1, date: date, amount: history.isIncome ? 0 : amount))
            }
        }
        
        var sections = [HistoryListSectionHeader](days)
        sections = sections.sorted(by: {$0.date < $1.date})
        return sections
    }
    
    private func setupDays(from startDate: Date?, to endDate: Date?) {
        dayStackView.removeAllArrangedSubviews()
        guard let startDate = travelItemViewModel?.startDate,
            let endDate = travelItemViewModel?.endDate else { return }
        let days = startDate.getPeriodOfDates(with: endDate)
        days.forEach { setupDayCell(with: $0) }
    }
    
    private func setupDayCell(with date: Date) {
        let view = DayCell(frame: CGRect(), date: date)
        view.delegate = self
        dayStackView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/7).isActive = true
    }
    
    private func deselectAllButtons() {
        allButton.configureDeselectedButton()
        prepareButton.configureDeselectedButton()
        selectedDateButton = nil
        
        let subviews = dayStackView.subviews
        for view in subviews {
            if let button = view.subviews.filter({ $0 is UIButton }).first as? UIButton {
                button.configureDeselectedButton()
            }
        }
    }
    
    @IBAction func moneySegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            historyFilter.isCardOnly = nil
        case 1:
            historyFilter.isCardOnly = false
        default:
            historyFilter.isCardOnly = true
        }
        let filteredHistory = historyFilter.filterHistories(with: travelItemViewModel?.histories)
        applySnapshot(with: filteredHistory)
        configureHistoryGuideLabel(filteredHistory: filteredHistory)
        setTotalAmountView()
    }
    
    @IBAction func isPrepareButtonTapped(_ sender: UIButton) {
        deselectAllButtons()
        sender.configureSelectedButton()
        historyFilter.isPrepareOnly = sender == prepareButton ? true : false
        historyFilter.selectedDate = nil
        
        let filteredHistory = historyFilter.filterHistories(with: travelItemViewModel?.histories)
        configureHistoryGuideLabel(filteredHistory: filteredHistory)
        applySnapshot(with: filteredHistory)
        
        setTotalAmountView()
    }
}

extension HistoryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedHistoryViewModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let detailhistoryViewModel = BaseHistoryViewModel(id: selectedHistoryViewModel.id,
                                                          isIncome: selectedHistoryViewModel.isIncome,
                                                          flagImage: self.travelItemViewModel?.flagImage ?? Data(),
                                                          currencyCode: self.travelItemViewModel?.currencyCode ?? "",
                                                          currentDate: selectedHistoryViewModel.date,
                                                          exchangeRate: self.travelItemViewModel?.exchangeRate ?? 0,
                                                          isCard: selectedHistoryViewModel.isCard,
                                                          category: selectedHistoryViewModel.category,
                                                          title: selectedHistoryViewModel.title,
                                                          memo: selectedHistoryViewModel.memo,
                                                          image: selectedHistoryViewModel.image,
                                                          amount: selectedHistoryViewModel.amount,
                                                          isPrepare: selectedHistoryViewModel.isPrepare,
                                                          countryIdentifier: travelItemViewModel?.countryIdentifier)
        
        HistoryDetailViewController.present(at: self, baseHistoryViewModel: detailhistoryViewModel, historyItemViewModel: selectedHistoryViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height * 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HistoryHeaderCell.identifier) as? HistoryHeaderCell,
            // TODO: - 더 효율적으로 빈 headers 처리하는 방법 고민하기
            !headers.isEmpty
            else { return nil }
        
        guard let exchangeRate = travelItemViewModel?.exchangeRate else { return UIView() }
        headerView.configure(with: headers[section].dayNumber, date: headers[section].date, amount: headers[section].amount / exchangeRate)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
            guard let deletingHistoryId = self?.dataSource.itemIdentifier(for: indexPath)?.id,
                self?.travelItemViewModel?.deleteHistory(id: deletingHistoryId) == true
                else {
                    completion(false)
                    return
            }
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "수정") { [weak self] (_, _, completion) in
            
            guard let self = self,
                let travelItemViewModel = self.travelItemViewModel,
                let currentHistoryItemViewModel = self.dataSource.itemIdentifier(for: indexPath) else { return }
            
            let editHistoryViewModel = BaseHistoryViewModel(id: currentHistoryItemViewModel.id,
                                                            isIncome: currentHistoryItemViewModel.isIncome,
                                                            flagImage: travelItemViewModel.flagImage ?? Data(),
                                                            currencyCode: travelItemViewModel.currencyCode ?? "",
                                                            currentDate: currentHistoryItemViewModel.date,
                                                            exchangeRate: travelItemViewModel.exchangeRate,
                                                            isCard: currentHistoryItemViewModel.isCard,
                                                            category: currentHistoryItemViewModel.category,
                                                            title: currentHistoryItemViewModel.title,
                                                            memo: currentHistoryItemViewModel.memo,
                                                            image: currentHistoryItemViewModel.image,
                                                            amount: currentHistoryItemViewModel.amount,
                                                            isPrepare: currentHistoryItemViewModel.isPrepare)
            
            let onPresent: (() -> Void)  = {
                self.closeFloatingActions { _ in}
            }
            
            AddHistoryViewController.present(at: self,
                                             delegateTarget: self,
                                             baseHistoryViewModel: editHistoryViewModel,
                                             onPresent: onPresent,
                                             onDismiss: nil)
            completion(true)
        }
        editAction.backgroundColor = UIColor(named: "mainColor")
        deleteAction.backgroundColor = UIColor(named: "deleteTextColor")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension HistoryListViewController: DayButtonDelegate {
    func dayButtonTapped(_ sender: UIButton) {
        deselectAllButtons()
        let subviews = dayStackView.subviews
        for index in 0..<subviews.count {
            if let _ = subviews[index].subviews.filter({ $0 == sender }).first as? UIButton {
                guard let startDate = travelItemViewModel?.startDate,
                    let tappedDate = Calendar.current.date(byAdding: .day, value: index, to: startDate) else { return }
                historyFilter.selectedDate = tappedDate
                historyFilter.isPrepareOnly = nil
            }
        }
        let filteredHistory = historyFilter.filterHistories(with: travelItemViewModel?.histories)
        configureHistoryGuideLabel(filteredHistory: filteredHistory)
        applySnapshot(with: filteredHistory)
        setTotalAmountView()
    }
}

extension HistoryListViewController: AddHistoryDelegate {
    
    func createHistory(newHistoryData: NewHistoryData) {
        travelItemViewModel?.createHistory(id: UUID(), isIncome: newHistoryData.isIncome, title: newHistoryData.title, memo: newHistoryData.memo, date: newHistoryData.date, image: newHistoryData.image, amount: newHistoryData.amount, category: newHistoryData.category, isPrepare: historyFilter.isPrepareOnly ?? false, isCard: newHistoryData.isCard ?? false) { _ in }
    }
    
    func updateHistory(at historyId: UUID?, newHistoryData: NewHistoryData) {
        guard let travelItemViewModel = travelItemViewModel else { return }
        travelItemViewModel.updateHistory(id: historyId ?? UUID(), isIncome: newHistoryData.isIncome, title: newHistoryData.title, memo: newHistoryData.memo, date: newHistoryData.date, image: newHistoryData.image, amount: newHistoryData.amount, category: newHistoryData.category, isPrepare: newHistoryData.isPrepare, isCard: newHistoryData.isCard ?? false) { result in
            if result {
//                print("지출/예산 업데이트 성공")
            } else {
//                print("지출/예산 업데이트 실패")
            }
        }
    }
}

extension HistoryListViewController: HistoryDetailDelegate {
    
    func deleteHistory(id: UUID?) {
        if let travelItemViewModel = travelItemViewModel,
            let deletingId = id,
            travelItemViewModel.deleteHistory(id: deletingId) {
//            print("기록을 삭제했습니다.")
        } else {
//            print("기록 삭제에 실패했습니다.")
        }
    }
    
    func updateHistory(at historyId: UUID?, updatedHistoryData: NewHistoryData) {
        guard let travelItemViewModel = travelItemViewModel else { return }
        travelItemViewModel.updateHistory(id: historyId ?? UUID(), isIncome: updatedHistoryData.isIncome, title: updatedHistoryData.title, memo: updatedHistoryData.memo, date: updatedHistoryData.date, image: updatedHistoryData.image, amount: updatedHistoryData.amount, category: updatedHistoryData.category, isPrepare: updatedHistoryData.isPrepare, isCard: updatedHistoryData.isCard ?? false) { result in
            if result {
//                print("지출/예산 업데이트 성공")
            } else {
//                print("지출/예산 업데이트 실패")
            }
        }
    }
}
