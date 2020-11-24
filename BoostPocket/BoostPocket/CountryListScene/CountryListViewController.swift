//
//  CountryListViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class CountryListViewController: UIViewController {
    
    var countries: [String] = ["a", "b", "c", "d", "e"]
    var doneButtonHandler: (() -> Void)?
    var countryListViewModel: CountryListPresentable?
    
    @IBOutlet weak var countryListTableView: UITableView!
    @IBOutlet weak var countrySearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        TableViewConfigure()
        NavigationBarConfigure()
        countryListViewModel?.needFetchItems()
    }
    
    private func TableViewConfigure() {
        countryListTableView.register(UINib.init(nibName: CountryCell.identifier, bundle: .main), forCellReuseIdentifier: CountryCell.identifier)
        countryListTableView.dataSource = self
        countryListTableView.delegate = self

    }
    
    private func NavigationBarConfigure() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        title = "여행할 나라를 선택해주세요"
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped() {
        if let selectedIndexPath = countryListTableView.indexPathForSelectedRow {
            // countries[selectedIndexPath.row]
        }
        dismiss(animated: true) { [weak self] in
            self?.doneButtonHandler?()
        }
    }
}

extension CountryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryListViewModel?.numberOfItem() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.identifier, for: indexPath) as? CountryCell,
              let cellViewModel = countryListViewModel?.cellForItemAt(path: indexPath) else { return UITableViewCell() }
        cell.configure(with: cellViewModel)
        return cell
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
