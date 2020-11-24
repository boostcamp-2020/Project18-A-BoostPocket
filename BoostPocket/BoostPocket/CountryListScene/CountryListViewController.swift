//
//  CountryListViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class CountryListViewController: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, CountryItemViewModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, CountryItemViewModel>
    
    var dataSource: DataSource!
    var doneButtonHandler: (() -> Void)?
    var countryListViewModel: CountryListPresentable? {
        didSet {
            countryListViewModel?.didFetch = { [weak self] fetchedCountries in
                guard let self = self else { return }
                var snapshot = SnapShot()
                snapshot.appendSections([.main])
                snapshot.appendItems(fetchedCountries)
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    @IBOutlet weak var countryListTableView: UITableView!
    @IBOutlet weak var countrySearchBar: UISearchBar!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        countryListViewModel?.needFetchItems()
    }
    
    private func configureTableView() {
        countryListTableView.delegate = self
        countryListTableView.register(UINib.init(nibName: CountryCell.identifier, bundle: .main), forCellReuseIdentifier: CountryCell.identifier)
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        title = "여행할 나라를 선택해주세요"
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: countryListTableView, cellProvider: { (countryListTableView, indexPath, countryItemViewModel) -> UITableViewCell? in
            guard let cell = countryListTableView.dequeueReusableCell(withIdentifier: CountryCell.identifier, for: indexPath) as? CountryCell else { return UITableViewCell() }
            
            if let selectedRow = countryListTableView.indexPathForSelectedRow, selectedRow == indexPath {
                cell.accessoryType = .checkmark
            }
            
            cell.configure(with: countryItemViewModel)
            return cell
        })
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped() {
        if countryListTableView.indexPathForSelectedRow != nil {
            // 선택된 셀이 있을 때
        } else {
            // 국가를 선택하지 않았을 때
        }
        
        dismiss(animated: true) { [weak self] in
            self?.doneButtonHandler?()
        }
    }
}

extension CountryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = countryListTableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .none
    }
}

extension CountryListViewController {
    enum Section {
        case main
    }
}
