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
    var doneButtonHandler: ((CountryItemViewModel) -> Void)?
    var countryListViewModel: CountryListPresentable? {
        didSet {
            countryListViewModel?.didFetch = { [weak self] fetchedCountries in
                guard let self = self else { return }
                
                fetchedCountries.forEach { country in
                    let countrySection = String(country.name.prefix(1))
                    print(countrySection)
                }
                
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
        countrySearchBar.delegate = self
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
    
    @objc func doneButtonTapped() {
        guard let selectedIndexPath = countryListTableView.indexPathForSelectedRow else {
            // 선택하지 않았을 때
            dismiss(animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true) { [weak self] in
            guard let selectedCountryItemViewModel = self?.countryListViewModel?.cellForItemAt(path: selectedIndexPath) else {
                // TODO: - 에러처리
                return
            }
            self?.doneButtonHandler?(selectedCountryItemViewModel)
        }
    }
    
    private func applySnapShot(with countries: [CountryItemViewModel]) {
        
        
        var snapshot = SnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(countries)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func filterContentForSearchText(_ query: String) {
        let countries = countryListViewModel?.countries
        let filteredCountries = countries?.filter { (country) -> Bool in
            return country.name.lowercased().contains(query.lowercased())
        }
        
        applySnapShot(with: filteredCountries ?? [])
    }
}

extension CountryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
}

extension CountryListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        
        applySnapShot(with: countryListViewModel?.countries ?? [])
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            applySnapShot(with: countryListViewModel?.countries ?? [])
        } else {
            filterContentForSearchText(searchText)
        }
    }
    
}
