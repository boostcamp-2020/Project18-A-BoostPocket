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
            
            /*
            // 2주차 데모 내용에서 제외
            let storyboard = UIStoryboard(name: "TravelDetail", bundle: nil)
            guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: TravelDetailTabbarController.identifier) as? TravelDetailTabbarController else { return }
            
            self.navigationController?.pushViewController(tabBarVC, animated: true)
             */
        }
        
        let navigationController = UINavigationController(rootViewController: countryListVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
}

extension TravelListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.width * 0.8
        return CGSize(width: width, height: width)
    }
}

extension TravelListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedTravelViewModel = travelListViewModel?.cellForItemAt(path: indexPath) else { return }
        
        let storyboard = UIStoryboard(name: "TravelDetail", bundle: nil)
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: TravelDetailTabbarController.identifier) as? TravelDetailTabbarController,
            let profileVC = tabBarVC.viewControllers?[0] as? TravelProfileViewController
            else { return }
        
        tabBarVC.setupChildViewControllers(with: selectedTravelViewModel)
        profileVC.deleteButtonHandler = {
            print("delete button tapped!")
        }
        
        self.navigationController?.pushViewController(tabBarVC, animated: true)
    }
}

extension Data {
    func getCoverImage() -> Data? {
        let randomNumber = Int.random(in: 1...7)
        return UIImage(named: "cover\(randomNumber)")?.pngData()
    }
}
