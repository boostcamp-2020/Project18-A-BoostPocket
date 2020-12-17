//
//  CountryListViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit
import Toaster

class CountryListViewController: UIViewController {
    static let identifier = "CountryListViewController"
    
    typealias DataSource = SectionTitledDiffableDataSource<String, CountryItemViewModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<String, CountryItemViewModel>
    
    var dataSource: DataSource!
    var doneButtonHandler: ((CountryItemViewModel) -> Void)?
    var countryListViewModel: CountryListPresentable?
    
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
        super.viewWillAppear(animated)
        countryListViewModel?.needFetchItems()
        countryListViewModel?.didFetch = { [weak self] fetchedCountries in
            self?.applySnapShot(with: fetchedCountries)
        }
    }
    
    private func configureTableView() {
        countryListTableView.delegate = self
        countryListTableView.sectionIndexColor = UIColor(named: "mainColor")
        countryListTableView.register(UINib.init(nibName: CountryCell.identifier, bundle: .main), forCellReuseIdentifier: CountryCell.identifier)
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "mainColor")
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
        guard let selectedIndexPath = countryListTableView.indexPathForSelectedRow else { return }
        
        dismiss(animated: true) { [weak self] in
            guard let selectedCountryItemViewModel = self?.dataSource.itemIdentifier(for: selectedIndexPath) else {
                return
            }
            self?.doneButtonHandler?(selectedCountryItemViewModel)
        }
    }
    
    private func applySnapShot(with countries: [CountryItemViewModel]) {
        guard !countries.isEmpty else {
            let alertToast = Toast(text: "네트워크를 연결하고 앱을 재실행하세요", duration: Delay.short)
            alertToast.show()
            return
        }
        
        var snapshot = SnapShot()
        let sections = self.setupSection(with: countries)
        snapshot.appendSections(sections)
        
        countries.forEach { country in
            if let consonant = String(country.name.prefix(1)).firstConsonant {
                snapshot.appendItems([country], toSection: consonant)
            }
        }
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func filterContentForSearchText(_ query: String) {
        let countries = countryListViewModel?.countries
        let filteredCountries = countries?.filter { (country) -> Bool in
            return country.name.lowercased().contains(query.lowercased())
        }
        
        applySnapShot(with: filteredCountries ?? [])
    }
    
    private func setupSection(with countries: [CountryItemViewModel]) -> [String] {
        var consonants = Set<String>()
        countries.forEach { country in
            if let consonant = String(country.name.prefix(1)).firstConsonant {
                consonants.insert(consonant)
            }
        }
        var sections = [String](consonants)
        sections = sections.sorted(by: {$0 < $1})
        return sections
    }
}

extension CountryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndexPath = tableView.indexPathForSelectedRow, selectedIndexPath == indexPath {
          navigationItem.rightBarButtonItem?.isEnabled = false
          tableView.deselectRow(at: indexPath, animated: true)
          let cell = tableView.cellForRow(at: indexPath)
          cell?.accessoryType = .none
          return nil
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        let cell = tableView.cellForRow(at: indexPath)
        cell?.tintColor = UIColor(named: "mainColor")
        cell?.accessoryType = .checkmark
        
        return indexPath
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

class SectionTitledDiffableDataSource<SectionIdentifierType, ItemIdentifierType>: UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    where SectionIdentifierType: Hashable, ItemIdentifierType: Hashable {
    
    var useSectionIndex: Bool = true
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {

        return snapshot().sectionIdentifiers.compactMap { $0 as? String }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return snapshot().sectionIdentifiers[section] as? String
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard useSectionIndex else { return 0 }
        return snapshot().sectionIdentifiers.firstIndex(where: { ($0 as? String) == title }) ?? 0
    }
}
