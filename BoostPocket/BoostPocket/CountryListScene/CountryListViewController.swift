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
        TableViewConfigure()
        NavigationBarConfigure()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        countryListViewModel?.needFetchItems()
    }
    
    private func TableViewConfigure() {
        countryListTableView.register(UINib.init(nibName: CountryCell.identifier, bundle: .main), forCellReuseIdentifier: CountryCell.identifier)
    }
    
    private func NavigationBarConfigure() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        title = "여행할 나라를 선택해주세요"
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: countryListTableView, cellProvider: { (countryListTableView, indexPath, countryItemViewModel) -> UITableViewCell? in
            guard let cell = countryListTableView.dequeueReusableCell(withIdentifier: CountryCell.identifier, for: indexPath) as? CountryCell else { return UITableViewCell() }
            
            cell.configure(with: countryItemViewModel)
            return cell
        })
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped() {
        if countryListTableView.indexPathForSelectedRow != nil {
            // countries[selectedIndexPath.row]
        }
        dismiss(animated: true) { [weak self] in
            self?.doneButtonHandler?()
        }
    }
}

extension CountryListViewController {
    enum Section {
        case main
    }
}
