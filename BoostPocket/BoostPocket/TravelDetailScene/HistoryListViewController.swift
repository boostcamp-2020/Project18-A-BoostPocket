//
//  HistoryListViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

enum HistoryListSection {
    case main
}

struct DummyHistory: Hashable {
    var category: HistoryCategory
    var title: String
    var amount: Double
    var date: Date
}

import UIKit

class HistoryListViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<HistoryListSection, DummyHistory>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HistoryListSection, DummyHistory>

    @IBOutlet weak var historyListTableView: UITableView!
    
    private lazy var dataSource = configureDatasource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyListTableView.delegate = self
        historyListTableView.register(HistoryCell.getNib(), forCellReuseIdentifier: HistoryCell.identifier)
        let dummyVM = [
            DummyHistory(category: .food, title: "마라탕", amount: 18000, date: "2020-11-23".convertToDate()),
            DummyHistory(category: .food, title: "파스타", amount: 12000, date: "2020-11-25".convertToDate()),
            DummyHistory(category: .food, title: "김치찌개", amount: 10000, date: "2020-12-01".convertToDate()),
            DummyHistory(category: .income, title: "수입", amount: 100000, date: "2020-10-23".convertToDate())
        ]
        applySnapshot(with: dummyVM)
    }
    
    private func configureDatasource() -> DataSource {
        let datasource = DataSource(tableView: historyListTableView) { (tableview, indexPath, item) -> UITableViewCell? in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else { return UITableViewCell() }
            cell.configure(with: item)
            
            return cell
        }
        return datasource
    }
    
    private func applySnapshot(with histories: [DummyHistory]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        histories.forEach { history in
            snapshot.appendItems([history], toSection: .main)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension HistoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height * 0.1
    }
}
