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
    
    lazy var dataSource: DataSource = configureDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        travelListViewModel?.needFetchItems()
    }
    
    private func configureCollectionView() {
        travelListCollectionView.delegate = self
        travelListCollectionView.register(TravelCell.getNib(), forCellWithReuseIdentifier: TravelCell.identifier)
        travelListCollectionView.register(TravelHeaderCell.getNib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TravelHeaderCell.identifier)
    }
    
    private func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: travelListCollectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TravelCell.identifier, for: indexPath) as? TravelCell else { return UICollectionViewCell() }
            cell.configure(with: item)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TravelHeaderCell.identifier, for: indexPath) as? TravelHeaderCell else { return UICollectionReusableView() }
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .current:
                sectionHeader.configure(with: "현재 여행 중인 나라")
            case .past:
                sectionHeader.configure(with: "지난 여행")
            case .upcoming:
                sectionHeader.configure(with: "다가오는 여행")
            }
            return sectionHeader
        }
        return dataSource
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

extension TravelListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //        let cell = collectionView.cellForItem(at: indexPath)
        //        cell?.safeAreaInsets = UIEdgeInsets(top: <#T##CGFloat#>, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>)
        let width = self.view.bounds.width * 0.8
        
        return CGSize(width: width, height: width)
    }
}

extension TravelListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let section = dataSource.snapshot().sectionIdentifiers[section]
        if section == .current {
            return CGSize(width: self.view.bounds.width, height: 100)
        }
        return CGSize(width: self.view.bounds.width, height: 50)
    }
}

extension Data {
    func getCoverImage() -> Data? {
        let randomNumber = Int.random(in: 1...7)
        return UIImage(named: "cover\(randomNumber)")?.pngData()
    }
}
