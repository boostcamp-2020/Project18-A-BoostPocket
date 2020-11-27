//
//  TravleListViewModel.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/24.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol TravelListPresentable {
    var travels: [TravelItemViewModel] { get }
    func createCountryListViewModel() -> CountryListViewModel?
    var didFetch: (([TravelItemViewModel]) -> Void)? { get set }

    func needFetchItems()
    @discardableResult func createTravel(countryName: String) -> TravelItemViewModel?
    func cellForItemAt(path: IndexPath) -> TravelItemViewModel?
    func numberOfItem() -> Int
    func deleteTravel(id: UUID) -> Bool
}

class TravelListViewModel: TravelListPresentable {
    
    var travels: [TravelItemViewModel] = [] {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.didFetch?(newValue)
            }
        }
    }
    var didFetch: (([TravelItemViewModel]) -> Void)?
    private weak var countryProvider: CountryProvidable?
    private weak var travelProvider: TravelProvidable?
    
    init(countryProvider: CountryProvidable?, travelProvider: TravelProvidable?) {
        self.countryProvider = countryProvider
        self.travelProvider = travelProvider
    }
    
    func needFetchItems() {
        guard let fetchedTravels = travelProvider?.fetchTravels() else { return }
        travels.removeAll()
        var newTravelItemViewModels: [TravelItemViewModel] = []
        fetchedTravels.forEach { travel in
            newTravelItemViewModels.append(TravelItemViewModel(travel: travel))
        }
        travels = newTravelItemViewModels
    }
    
    func createTravel(countryName: String) -> TravelItemViewModel? {
        guard let createdTravel = travelProvider?.createTravel(countryName: countryName) else { return nil }
        let createdTravelItemViewModel = TravelItemViewModel(travel: createdTravel)
        travels.append(createdTravelItemViewModel)
        return createdTravelItemViewModel
    }
    
    func deleteTravel(id: UUID) -> Bool {
        if let travelProvider = travelProvider,
            travelProvider.deleteTravel(id: id),
            let indexToDelete = travels.indices.filter({ travels[$0].id == id }).first {
            travels.remove(at: indexToDelete)
            return true
        }
        return false
    }
    
    func cellForItemAt(path: IndexPath) -> TravelItemViewModel? {
        return travels[path.row]
    }
    
    func numberOfItem() -> Int {
        return travels.count
    }
    
}

extension TravelListViewModel {
    func createCountryListViewModel() -> CountryListViewModel? {
        guard let countryProvider = countryProvider else { return nil }
        return CountryListViewModel(countryProvider: countryProvider)
    }
}
