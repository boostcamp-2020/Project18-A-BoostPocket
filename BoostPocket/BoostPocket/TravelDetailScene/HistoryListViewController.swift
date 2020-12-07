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
    
    lazy var buttons = [self.addExpenseButton, self.addIncomeButton]
    lazy var floatingDimView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.alpha = 0
        view.isHidden = true
        
        self.view.insertSubview(view, belowSubview: self.floatingStackView)
        
        return view
    }()
    
    weak var travelItemViewModel: HistoryListPresentable?

    private var historyFilter = HistoryFilter()
    private var isFloatingButtonOpened: Bool = false
    private lazy var dataSource = configureDatasource()
    private lazy var headers = setupSection(with: travelItemViewModel?.histories ?? [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDays(from: travelItemViewModel?.startDate, to: travelItemViewModel?.endDate)
        moneySegmentedControl.selectedSegmentIndex = 0
    }
    
    // MARK: - Configuration
    
    private func configure() {
        configureTravelItemViewModel()
        configureTableView()
        configureSegmentedControl()
        configureFloatingActionButton()
        setTotalAmountView()
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
        historyListTableView.register(HistoryCell.getNib(), forCellReuseIdentifier: HistoryCell.identifier)
        historyListTableView.register(HistoryHeaderCell.getNib(), forHeaderFooterViewReuseIdentifier: HistoryHeaderCell.identifier)
    }
    
    private func configureDatasource() -> DataSource {
        let datasource = DataSource(tableView: historyListTableView) { (tableview, indexPath, item) -> UITableViewCell? in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else { return UITableViewCell() }
            
            cell.selectionStyle = .none
            cell.configure(with: item)
            return cell
        }
        
        return datasource
    }
    
    private func configureFloatingActionButton() {
        let buttonWidth = self.view.bounds.width * 0.1
        
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
        let expenses = filteredHistories.filter({ !$0.isIncome }).reduce(0) { $0 + $1.amount }
        let allAmount = filteredHistories.reduce(0) { $0 + $1.amount }
        
        self.totalAmountView.configure(withExpense: expenses, remain: allAmount - 2 * expenses)
    }
    
    private func configureTravelItemViewModel() {
        travelItemViewModel?.needFetchItems()
        travelItemViewModel?.didFetch = { [weak self] _ in
            guard let self = self else { return }
            self.historyListTableView.reloadData()
            self.applySnapshot(with: self.historyFilter.filterHistories(with: self.travelItemViewModel?.histories))
        }
    }
    
    // MARK: - Floating Action Button
    
    @IBAction func floatingActionButtonTapped(_ sender: UIButton) {
        switch isFloatingButtonOpened {
        case true:
            closeFloatingActions()
        case false:
            openFloatingActions()
        }
    }
    
    private func closeFloatingActions() {
        buttons.reversed().forEach { [weak self] button in
            UIView.animate(withDuration: 0.2) {
                button?.isHidden = true
                self?.view.layoutIfNeeded()
            }
        }
        
//        UIView.animate(withDuration: 0.5, animations: { self.floatingDimView.alpha = 0 }) { _ in
//            self.floatingDimView.isHidden = true
//        }
        
        isFloatingButtonOpened = false
        rotateFloatingActionButton()
    }
    
    private func openFloatingActions() {
        self.floatingDimView.isHidden = false
        
//        UIView.animate(withDuration: 0.5) { [weak self] in
//            self?.floatingDimView.alpha = 1
//        }
        
        buttons.forEach { [weak self] button in
            button?.isHidden = false
            button?.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                button?.alpha = 1
                self?.view.layoutIfNeeded()
            }
        }
        
        isFloatingButtonOpened = true
        rotateFloatingActionButton()
    }
    
    private func rotateFloatingActionButton() {
        let roatation = isFloatingButtonOpened ? CGAffineTransform(rotationAngle: .pi - (.pi / 4)) : CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.floatingButton.transform = roatation
        }
    }
    
    @IBAction func addExpenseButtonTapped(_ sender: Any) {
        addNewHistory(isIncome: false)
    }
    
    @IBAction func addIncomeButtonTapped(_ sender: Any) {
        addNewHistory(isIncome: true)
    }
    
    private func addNewHistory(isIncome: Bool) {
        let newHistoryViewModel = BaseHistoryViewModel(isIncome: isIncome,
                                                      flagImage: self.travelItemViewModel?.flagImage ?? Data(),
                                                      currencyCode: self.travelItemViewModel?.currencyCode ?? "",
                                                      currentDate: self.historyFilter.selectedDate ?? Date(),
                                                      exchangeRate: self.travelItemViewModel?.exchangeRate ?? 0)
        
        let saveButtonHandler: ((NewHistoryData) -> Void)? = { [weak self] newHistoryData in
            // isPrepare은 현재 "준비" 버튼이 선택되었는지에 따라 true/false
            self?.travelItemViewModel?.createHistory(id: UUID(), isIncome: isIncome, title: newHistoryData.title, memo: newHistoryData.memo, date: newHistoryData.date, image: newHistoryData.image, amount: newHistoryData.amount, category: newHistoryData.category, isPrepare: self?.historyFilter.isPrepareOnly ?? false, isCard: newHistoryData.isCard ?? false) { _ in }
        }
        
        let onPresent: (() -> Void)  = { [weak self] in
            self?.closeFloatingActions()
        }
        
        AddHistoryViewController.present(at: self,
                                         newHistoryViewModel: newHistoryViewModel,
                                         saveButtonHandler: saveButtonHandler,
                                         onPresent: onPresent)
    }
    
    private func updateHistory(at indexPath: IndexPath) {
        guard let travelItemViewModel = self.travelItemViewModel,
            let currentHistoryItemViewModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let editHistoryViewModel = BaseHistoryViewModel(isIncome: currentHistoryItemViewModel.isIncome,
                                                       flagImage: travelItemViewModel.flagImage ?? Data(),
                                                       currencyCode: travelItemViewModel.currencyCode ?? "",
                                                       currentDate: currentHistoryItemViewModel.date,
                                                       exchangeRate: travelItemViewModel.exchangeRate,
                                                       isCard: currentHistoryItemViewModel.isCard,
                                                       category: currentHistoryItemViewModel.category,
                                                       title: currentHistoryItemViewModel.title,
                                                       memo: currentHistoryItemViewModel.memo,
                                                       image: currentHistoryItemViewModel.image,
                                                       amount: currentHistoryItemViewModel.amount)
        
        let saveButtonHandler: ((NewHistoryData) -> Void)? = { [weak self] newHistoryData in
            guard self?.travelItemViewModel?.updateHistory(id: currentHistoryItemViewModel.id ?? UUID(),
                                                    isIncome: currentHistoryItemViewModel.isIncome,
                                                    title: newHistoryData.title,
                                                    memo: newHistoryData.memo,
                                                    date: newHistoryData.date,
                                                    image: newHistoryData.image,
                                                    amount: newHistoryData.amount,
                                                    category: newHistoryData.category,
                                                    isPrepare: currentHistoryItemViewModel.isPrepare,
                                                    isCard: newHistoryData.isCard) == true
                else { return }
            print("지출/예산 업데이트 성공")
        }
        
        let onPresent: (() -> Void)  = { [weak self] in
            self?.closeFloatingActions()
        }
        
        AddHistoryViewController.present(at: self,
                                         newHistoryViewModel: editHistoryViewModel,
                                         saveButtonHandler: saveButtonHandler,
                                         onPresent: onPresent)
    }
    
    private func applySnapshot(with histories: [HistoryItemViewModel]) {
        var snapshot = Snapshot()
        headers = setupSection(with: histories)
        snapshot.appendSections(headers)
        histories.forEach { history in
            if let section = headers.filter({ history.date.convertToString(format: .dotted) == $0.date.convertToString(format: .dotted)}).first {
                snapshot.appendItems([history], toSection: section)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupSection(with histories: [HistoryItemViewModel]) -> [HistoryListSectionHeader] {
        guard let startDate = travelItemViewModel?.startDate else { return [] }
        var days = Set<HistoryListSectionHeader>()
        histories.forEach { history in
            let day = startDate.interval(ofComponent: .day, fromDate: history.date)
            let amount = history.amount
            let date = history.date
            if let day = days.filter({ date.convertToString(format: .dotted) == $0.date.convertToString(format: .dotted)}).first {
                day.amount += amount
            } else {
                days.insert(HistoryListSectionHeader(dayNumber: day + 1, date: date, amount: amount))
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
    
    private func DeselectAllButtons() {
        allButton.configureDeselectedButton()
        prepareButton.configureDeselectedButton()
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
        applySnapshot(with: historyFilter.filterHistories(with: travelItemViewModel?.histories))
        setTotalAmountView()
    }
    
    @IBAction func allButtonTapped(_ sender: UIButton) {
        DeselectAllButtons()
        sender.configureSelectedButton()
        historyFilter.isPrepareOnly = false
        historyFilter.selectedDate = nil
        applySnapshot(with: historyFilter.filterHistories(with: travelItemViewModel?.histories))
        setTotalAmountView()
    }
    
    @IBAction func prepareButtonTapped(_ sender: UIButton) {
        DeselectAllButtons()
        sender.configureSelectedButton()
        historyFilter.isPrepareOnly = true
        historyFilter.selectedDate = nil
        applySnapshot(with: historyFilter.filterHistories(with: travelItemViewModel?.histories))
        setTotalAmountView()
    }
}

extension HistoryListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedHistoryViewModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if let historyDetailVC = self.storyboard?.instantiateViewController(identifier: "HistoryDetailViewController") as? HistoryDetailViewController {
            
            let detailhistoryViewModel = BaseHistoryViewModel(isIncome: selectedHistoryViewModel.isIncome,
                                                        flagImage: self.travelItemViewModel?.flagImage ?? Data(),
                                                        currencyCode: self.travelItemViewModel?.currencyCode ?? "",
                                                        currentDate: self.historyFilter.selectedDate ?? Date(),
                                                        exchangeRate: self.travelItemViewModel?.exchangeRate ?? 0,
                                                        isCard: selectedHistoryViewModel.isCard,
                                                        category: selectedHistoryViewModel.category,
                                                        title: selectedHistoryViewModel.title,
                                                        memo: selectedHistoryViewModel.memo,
                                                        image: selectedHistoryViewModel.image,
                                                        amount: selectedHistoryViewModel.amount,
                                                        isPrepare: selectedHistoryViewModel.isPrepare)
            
            self.present(historyDetailVC, animated: true, completion: nil)
            historyDetailVC.configureViews(history: detailhistoryViewModel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height * 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HistoryHeaderCell.identifier) as? HistoryHeaderCell,
            // TODO: - 더 효율적으로 빈 headers 처리하는 방법 고민하기
            !headers.isEmpty
            else { return nil }
    
        // TODO: - Index out of range 오류 해결하기
        headerView.configure(with: headers[section].dayNumber, date: headers[section].date, amount: headers[section].amount)
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
            self?.updateHistory(at: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension HistoryListViewController: DayButtonDelegate {
    func dayButtonTapped(_ sender: UIButton) {
        DeselectAllButtons()
        let subviews = dayStackView.subviews
        for index in 0..<subviews.count {
            if let _ = subviews[index].subviews.filter({ $0 == sender }).first as? UIButton {
                guard let startDate = travelItemViewModel?.startDate,
                    let tappedDate = Calendar.current.date(byAdding: .day, value: index, to: startDate) else { return }
                historyFilter.selectedDate = tappedDate
                historyFilter.isPrepareOnly = nil
            }
        }
        applySnapshot(with: historyFilter.filterHistories(with: travelItemViewModel?.histories))
        setTotalAmountView()
    }
}
