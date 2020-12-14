//
//  ViewController.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class TravelListViewController: UIViewController {
    static let identifier = "TravelListViewController"
    
    typealias DataSource = UICollectionViewDiffableDataSource<TravelSection, TravelItemViewModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<TravelSection, TravelItemViewModel>
    
    private(set) var layout: Layout = .defaultLayout
    private lazy var dataSource: DataSource = configureDataSource()
    var travelListViewModel: TravelListPresentable?
    weak var presenter: TravelListVCPresenter?
    
    @IBOutlet weak var travelListCollectionView: UICollectionView!
    @IBOutlet var layoutButtons: [UIButton]!
    @IBOutlet weak var newTravelIndicateView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.onViewDidLoad()
        presentLoadingView()
        configureCollectionView()
        travelListViewModel?.didFetch = { [weak self] fetchedTravels in
            self?.applySnapShot(with: fetchedTravels)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        travelListViewModel?.needFetchItems()
        configureNewTravelIndicateView()
    }
    
    private func configureCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 15
        travelListCollectionView.setCollectionViewLayout(flowLayout, animated: true)
        
        travelListCollectionView.dataSource = dataSource
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
            sectionHeader.configure(with: section.travelSectionCase, numberOfTravel: section.numberOfTravels)
            
            return sectionHeader
        }
        
        return dataSource
    }
    
    private func configureNewTravelIndicateView() {
        if travelListViewModel?.numberOfItem() != 0 {
            newTravelIndicateView.isHidden = true
        } else {
            newTravelIndicateView.isHidden = false
        }
    }
    
    private func presentLoadingView() {
        self.navigationController?.navigationBar.isHidden = true
        let curveView = CurveView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        curveView.center = self.view.center
        self.view.addSubview(curveView)
    }
    
    func applySnapShot(with travels: [TravelItemViewModel]) {
        var snapShot = SnapShot()
        
        let sectionCaseCounts = getTravelSectionNumbers()
        
        snapShot.appendSections([TravelSection(travelSectionCase: .current, numberOfTravels: sectionCaseCounts[.current] ?? 0),
                                 TravelSection(travelSectionCase: .past, numberOfTravels: sectionCaseCounts[.past] ?? 0),
                                 TravelSection(travelSectionCase: .upcoming, numberOfTravels: sectionCaseCounts[.upcoming] ?? 0)])
        
        travels.forEach { travel in
            let section = getTravelSectionCase(with: travel)
            snapShot.appendItems([travel], toSection: TravelSection(travelSectionCase: section, numberOfTravels: sectionCaseCounts[section] ?? 0))
        }
        
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    private func getTravelSectionNumbers() -> [TravelSectionCase: Int] {
        guard let travels = travelListViewModel?.travels else { return [:] }
        
        var counts: [TravelSectionCase: Int] = [ .current: 0,
                                                 .past: 0,
                                                 .upcoming: 0]
        
        travels.forEach { travel in
            let travelSectionCase = getTravelSectionCase(with: travel)
            counts[travelSectionCase] = (counts[travelSectionCase] ?? 0) + 1
        }
        
        if let past = counts[.past], let upcoming = counts[.upcoming] {
            counts[.current] = (counts[.current] ?? 0) + past + upcoming
        }
        
        return counts
    }
    
    private func getTravelSectionCase(with travel: TravelItemViewModel) -> TravelSectionCase {
        let today = Date()
        guard let startDate = travel.startDate, let endDate = travel.endDate else { return .upcoming }
        
        if endDate < today {
            return .past
        } else if startDate > today {
            return .upcoming
        }
        return .current
    }
    
    private func resetAlphaOfLayoutButtons() {
        layoutButtons.forEach { $0.alpha = 0.5 }
    }
    
    @IBAction func layoutButtonTapped(_ sender: UIButton) {
        presenter?.onLayoutButtonTapped()
        
        resetAlphaOfLayoutButtons()
        sender.alpha = 1
        
        let index = layoutButtons.firstIndex(of: sender)
        switch index {
        case 0:
            layout = .defaultLayout
            presenter?.onDefaultLayoutButtonTapped()
        case 1:
            layout = .squareLayout
            presenter?.onSquareLayoutButtonTapped()
        case 2:
            layout = .rectangleLayout
            presenter?.onRectangleLayoutButtonTapped()
        default:
            break
        }
        applySnapShot(with: travelListViewModel?.travels ?? [])
    }
    
    @IBAction func newTravelButtonTapped(_ sender: Any) {
        let countryListVC = CountryListViewController.init(nibName: CountryListViewController.identifier, bundle: nil)
        
        guard let countryListViewModel = travelListViewModel?.createCountryListViewModel() else { return }
        
        countryListVC.countryListViewModel = countryListViewModel
        countryListVC.doneButtonHandler = { (selectedCountry) in
            self.travelListViewModel?.createTravel(countryName: selectedCountry.name) { travelItemViewModel in
                DispatchQueue.main.async {
                    guard let createdTravelItemViewModel = travelItemViewModel,
                        let tabBarVC = TravelDetailTabbarController.createTabbarVC(),
                        let profileVC = tabBarVC.viewControllers?[0] as? TravelProfileViewController
                        else { return }
                    
                    tabBarVC.setupChildViewControllers(with: createdTravelItemViewModel)
                    profileVC.profileDelegate = self
                    self.navigationController?.pushViewController(tabBarVC, animated: true)
                }
            }
        }
        
        let navigationController = UINavigationController(rootViewController: countryListVC)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension TravelListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = self.view.bounds.width * 0.9
        var height: CGFloat = self.view.bounds.height * 0.25
        
        switch layout {
        case .defaultLayout:
            height = width
        case .squareLayout:
            width = (collectionView.bounds.width - 15 * 3) / 2
            height = width
        default:
            break
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
        guard let selectedTravelViewModel = dataSource.itemIdentifier(for: indexPath),
            let tabBarVC = TravelDetailTabbarController.createTabbarVC(),
            let profileVC = tabBarVC.viewControllers?[0] as? TravelProfileViewController
            else { return }
        
        tabBarVC.setupChildViewControllers(with: selectedTravelViewModel)
        profileVC.profileDelegate = self
        
        self.navigationController?.pushViewController(tabBarVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let section = dataSource.snapshot().sectionIdentifiers[section]
        if section.travelSectionCase == .current {
            return CGSize(width: self.view.bounds.width, height: 100)
        }
        return CGSize(width: self.view.bounds.width, height: 50)
    }
    
}

extension TravelListViewController: TravelProfileDelegate {
    
    func deleteTravel(id: UUID?) {
        if let travelListViewModel = travelListViewModel,
            let deletingId = id,
            travelListViewModel.deleteTravel(id: deletingId) {
            print("여행을 삭제했습니다.")
        } else {
            print("여행 삭제에 실패했습니다.")
        }
    }
    
    func updateTravel(id: UUID? = nil, newTitle: String? = nil, newMemo: String? = nil, newStartDate: Date? = nil, newEndDate: Date? = nil, newCoverImage: Data? = nil, newBudget: Double? = nil, newExchangeRate: Double? = nil, completion: @escaping (Bool) -> Void) {
        presenter?.onUpdateTravel()
        
        if let travelListViewModel = travelListViewModel,
            let updatingId = id,
            let updatingTravel = travelListViewModel.travels.filter({ $0.id == updatingId }).first,
            let countryName = updatingTravel.countryName,
            let title = updatingTravel.title,
            let coverImage = updatingTravel.coverImage {
            
            travelListViewModel.updateTravel(countryName: countryName, id: updatingId, title: newTitle ?? title, memo: newMemo, startDate: newStartDate, endDate: newEndDate, coverImage: newCoverImage ?? coverImage, budget: newBudget ?? updatingTravel.budget, exchangeRate: newExchangeRate ?? updatingTravel.exchangeRate) { result in
                if result {
                    print("여행 정보 업데이트 성공")
                    completion(true)
                } else {
                    print("여행 정보 업데이트 실패")
                    completion(false)
                }
            }
        } else {
            print("여행 업데이트를 위한 정보 불러오기 실패")
            completion(false)
        }
    }
}
