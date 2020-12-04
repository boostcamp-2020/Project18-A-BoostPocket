//
//  HistoryListViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class HistoryListViewController: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<HistoryListSectionHeader, HistoryItemViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HistoryListSectionHeader, HistoryItemViewModel>
    
    @IBOutlet weak var historyListTableView: UITableView!
    @IBOutlet weak var dayStackView: UIStackView!
    @IBOutlet weak var moneySegmentedControl: UISegmentedControl!
    
    weak var travelItemViewModel: HistoryListPresentable?
    
    // 필터 조건 저장
    private var isPrepareOnly: Bool? = false
    private var date: Date?
    private var isCardOnly: Bool?
    
    private lazy var dataSource = configureDatasource()
    private lazy var headers = setupSection(with: travelItemViewModel?.histories ?? [])
    private lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(addExpenseHistory), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "새 지출 입력하기")
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSegmentedControl()
        // setupDays(from: travelItemViewModel?.startDate, to: travelItemViewModel?.endDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDays(from: travelItemViewModel?.startDate, to: travelItemViewModel?.endDate)
        moneySegmentedControl.selectedSegmentIndex = 0
        travelItemViewModel?.needFetchItems()
        
        travelItemViewModel?.didFetch = { [weak self] fetchedHistories in
            self?.historyListTableView.reloadData()
            self?.applySnapshot(with: fetchedHistories)
        }
    }

    @objc private func addExpenseHistory() {
        let addHistoryVC = AddHistoryViewController(nibName: AddHistoryViewController.identifier, bundle: nil)
        
        let baseData = BaseDataForAddingHistory(isIncome: false,
                                                flagImage: self.travelItemViewModel?.flagImage ?? Data(),
                                                currencyCode: self.travelItemViewModel?.currencyCode ?? "",
                                                exchangeRate: self.travelItemViewModel?.exchangeRate ?? 0)
        
        addHistoryVC.baseData = baseData
        addHistoryVC.saveButtonHandler = { [weak self] newExpenseData in
            // isPrepare은 현재 "준비" 버튼이 선택되었는지에 따라 true/false
            self?.travelItemViewModel?.createHistory(id: UUID(), isIncome: false, title: newExpenseData.title, memo: newExpenseData.memo, date: newExpenseData.date, image: newExpenseData.image ?? Data(), amount: newExpenseData.amount, category: newExpenseData.category, isPrepare: false, isCard: newExpenseData.isCard ?? false) { _ in }
        }
        self.present(addHistoryVC, animated: true) { [weak self] in
            self?.refresher.endRefreshing()
        }
    }
    
    private func configureSegmentedControl() {
        moneySegmentedControl.selectedSegmentTintColor = .clear
        moneySegmentedControl.backgroundColor = .none
        moneySegmentedControl.layer.backgroundColor = UIColor.clear.cgColor
        moneySegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNextCondensed-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        moneySegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNextCondensed-Medium", size: 16)!, NSAttributedString.Key.foregroundColor: UIColor(named: "mainColor") ?? UIColor.systemBlue], for: .selected)
    }
    
    private func configureTableView() {
        historyListTableView.refreshControl = refresher
        historyListTableView.delegate = self
        historyListTableView.register(HistoryCell.getNib(), forCellReuseIdentifier: HistoryCell.identifier)
        historyListTableView.register(HistoryHeaderCell.getNib(), forHeaderFooterViewReuseIdentifier: HistoryHeaderCell.identifier)
    }
    
    private func configureDatasource() -> DataSource {
        let datasource = DataSource(tableView: historyListTableView) { (tableview, indexPath, item) -> UITableViewCell? in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else { return UITableViewCell() }
            cell.configure(with: item)
            
            return cell
        }
        
        return datasource
    }
    
    private func applySnapshot(with histories: [HistoryItemViewModel]) {
        var snapshot = Snapshot()
        headers = setupSection(with: histories)
        snapshot.appendSections(headers)
        histories.forEach { history in
            if let section = headers.filter({ Calendar.current.isDate(history.date, inSameDayAs: $0.date) }).first {
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
            if let day = days.filter({ Calendar.current.isDate(date, inSameDayAs: $0.date) }).first {
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
        days.forEach { day in
            setupDayCell(with: day)
        }
    }
    
    private func setupDayCell(with date: Date) {
        let view = DayCell(frame: CGRect(), date: date)
        view.delegate = self
        dayStackView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/7).isActive = true
    }
    
    private func filterHistories(isPrepare: Bool?, date: Date?, isCard: Bool?) -> [HistoryItemViewModel] {
        var histories = travelItemViewModel?.histories ?? []
        if let card = isCard {
            histories = histories.filter { $0.isCard == card }
        }
        if let prepare = isPrepare, prepare {
            histories = histories.filter { $0.isPrepare == prepare }
        } else if let date = date {
            histories = histories.filter { Calendar.current.isDate(date, inSameDayAs: $0.date) }
        }
        return histories
    }
    
    @IBAction func moneySegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isCardOnly = nil
        case 1:
            isCardOnly = false
        default:
            isCardOnly = true
        }
        applySnapshot(with: filterHistories(isPrepare: isPrepareOnly, date: date, isCard: isCardOnly))
    }
    
    @IBAction func allButtonTapped(_ sender: UIButton) {
        isPrepareOnly = false
        date = nil
        applySnapshot(with: filterHistories(isPrepare: isPrepareOnly, date: date, isCard: isCardOnly))
    }
    
    @IBAction func prepareButtonTapped(_ sender: UIButton) {
        isPrepareOnly = true
        date = nil
        applySnapshot(with: filterHistories(isPrepare: isPrepareOnly, date: date, isCard: isCardOnly))
    }
    
}

extension HistoryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedHistoryViewModel = dataSource.itemIdentifier(for: indexPath) else { return }
        if let historyDetailVC = self.storyboard?.instantiateViewController(identifier: "HistoryDetailViewController") as? HistoryDetailViewController {
            self.present(historyDetailVC, animated: true, completion: nil)
            historyDetailVC.initDetailView(history: selectedHistoryViewModel)
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
        headerView.configure(with: headers[section].dayNumber, date: headers[section].date, amount: headers[section].amount)
        return headerView
    }
}

extension HistoryListViewController: DayButtonDelegate {
    func dayButtonTapped(_ sender: UIButton) {
        let subviews = dayStackView.subviews
        for index in 0..<subviews.count {
            if let _ = subviews[index].subviews.filter({ $0 == sender }).first as? UIButton {
                guard let startDate = travelItemViewModel?.startDate,
                      let tappedDate = Calendar.current.date(byAdding: .day, value: index, to: startDate) else { return }
                date = tappedDate
                isPrepareOnly = nil
                break
            }
        }
        applySnapshot(with: filterHistories(isPrepare: isPrepareOnly, date: self.date, isCard: isCardOnly))
    }
    
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
