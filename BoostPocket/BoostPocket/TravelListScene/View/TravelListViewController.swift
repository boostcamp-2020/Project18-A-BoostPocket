//
//  ViewController.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

enum Layout {
    case defaultLayout
    case squareLayout
    case rectangleLayout
    case hamburgerLayout
}

class TravelListViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<TravelSection, TravelItemViewModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<TravelSection, TravelItemViewModel>
    
    var layout: Layout = .defaultLayout
    lazy var dataSource: DataSource = configureDataSource()
    var travelListViewModel: TravelListPresentable? {
        didSet {
            travelListViewModel?.didFetch = { [weak self] fetchedTravels in
                self?.applySnapShot(with: fetchedTravels)
            }
        }
    }
    
    @IBOutlet weak var travelListCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        travelListViewModel?.needFetchItems()
    }
    
    private func configureCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        travelListCollectionView.setCollectionViewLayout(flowLayout, animated: true)
        
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
            // TODO: 여행 개수 찾는 방법 고민해보기..
            // let travelNumber = dataSource.snapshot().numberOfItems
            sectionHeader.configure(with: section, numberOfTravel: self.travelListViewModel?.travels.count ?? 0)
            
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
        
        // TODO: - reloadData 없이 구현하는 방법 고민하기
        dataSource.apply(snapShot, animatingDifferences: true) { [weak self] in
            self?.travelListCollectionView.reloadData()
        }
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
    
    @IBAction func newTravelButtonTapped(_ sender: UIButton) {
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
    
    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        layout = .defaultLayout
        applySnapShot(with: travelListViewModel?.travels ?? [])
    }
    
    @IBAction func squareLayoutButtonTapped(_ sender: UIButton) {
        layout = .squareLayout
        applySnapShot(with: travelListViewModel?.travels ?? [])
    }
    
    @IBAction func rectangleLayoutButtonTapped(_ sender: UIButton) {
        layout = .rectangleLayout
        applySnapShot(with: travelListViewModel?.travels ?? [])
    }
    
    @IBAction func hamburgerLayoutButtonTapped(_ sender: UIButton) {
        layout = .hamburgerLayout
        applySnapShot(with: travelListViewModel?.travels ?? [])
    }
    
}

extension TravelListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat
        var height: CGFloat
        
        switch layout {
        case .defaultLayout:
            width = self.view.bounds.width * 0.9
            height = width
        case .squareLayout:
            width = (collectionView.bounds.width - 15 * 3) / 2
            height = width
        case .rectangleLayout:
            width = self.view.bounds.width * 0.8
            height = 100
        case .hamburgerLayout:
            width = self.view.bounds.width * 0.8
            height = 100
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if layout == .squareLayout {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        profileVC.profileDelegate = self
        
        self.navigationController?.pushViewController(tabBarVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let section = dataSource.snapshot().sectionIdentifiers[section]
        if section == .current {
            return CGSize(width: self.view.bounds.width, height: 100)
        }
        return CGSize(width: self.view.bounds.width, height: 50)
        
    }
}

extension TravelListViewController: TravelItemProfileDelegate {
    func deleteTravel(id: UUID?) {
        if let travelListViewModel = travelListViewModel,
            let deletingId = id,
            travelListViewModel.deleteTravel(id: deletingId) {
            print("여행을 삭제했습니다.")
        } else {
            // TODO: - listVM, id, delete 과정 중 문제가 생겨 실패 시 사용자에게 noti
            print("여행 삭제에 실패했습니다.")
        }
    }
}
