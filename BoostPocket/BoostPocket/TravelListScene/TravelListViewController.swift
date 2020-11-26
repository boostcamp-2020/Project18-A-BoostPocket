//
//  ViewController.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TravelListViewController: UIViewController {
    
    var travelListViewModel: TravelListPresentable? {
        didSet {
            travelListViewModel?.didFetch = { [weak self] fetchedTravels in
                self?.applySnapShot(with: fetchedTravels)
            }
        }
    }

    @IBOutlet weak var travelListCollectionView: UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<TravelSection, TravelItemViewModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<TravelSection, TravelItemViewModel>
    
    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureDataSource()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        travelListViewModel?.needFetchItems()
    }
    
    private func configureCollectionView() {
        travelListCollectionView.delegate = self
        travelListCollectionView.register(TravelCell.getNib(), forCellWithReuseIdentifier: TravelCell.identifier)
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: travelListCollectionView, cellProvider: { (travelListCollectionView, indexPath, travelItemViewModel) -> UICollectionViewCell? in
            guard let cell = travelListCollectionView.dequeueReusableCell(withReuseIdentifier: TravelCell.identifier, for: indexPath) as? TravelCell
            else { return UICollectionViewCell() }
            
            cell.configure(with: travelItemViewModel)
            
            return cell
        })
    }
    
    func applySnapShot(with travels: [TravelItemViewModel]) {
        
        var snapShot = SnapShot()
        snapShot.appendSections([.current, .past, .upcoming])
        
        travels.forEach { travel in
            
            let section = getTravelSection(with: travel)
            snapShot.appendItems([travel], toSection: section)
        }
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    func getTravelSection(with travel: TravelItemViewModel) -> TravelSection {
        
        let today = Date()
        guard let startDate = travel.startDate, let endDate = travel.endDate else { return .upcoming }
        
        if endDate < today {
            return .past
        } else if startDate > today {
            return .upcoming
        }
        return .current
    }

    @IBAction func newTravelButtonTapped(_ sender: Any) {
        let countryListVC = CountryListViewController.init(nibName: "CountryListViewController", bundle: nil)

        guard let countryListViewModel = travelListViewModel?.createCountryListViewModel() else { return }
        
        countryListVC.countryListViewModel = countryListViewModel
        countryListVC.doneButtonHandler = { (selectedCountry) in
            dump(selectedCountry)
            self.travelListViewModel?.createTravel(countryName: selectedCountry.name)

//            let storyboard = UIStoryboard(name: "TravelDetail", bundle: nil)
//            guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else { return }
//            self.navigationController?.pushViewController(tabBarVC, animated: true)
        }
        
        let navigationController = UINavigationController(rootViewController: countryListVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
}

extension TravelListViewController: UICollectionViewDelegate {
    
    
}
