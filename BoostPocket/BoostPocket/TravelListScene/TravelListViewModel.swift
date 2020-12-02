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

    func createTravel(countryName: String, completion: @escaping (TravelItemViewModel?) -> Void)
    func needFetchItems()
    func cellForItemAt(id: UUID) -> TravelItemViewModel?
    func updateTravel(countryName: String, id: UUID, title: String, memo: String?, startDate: Date?, endDate: Date?, coverImage: Data, budget: Double, exchangeRate: Double) -> Bool
    func deleteTravel(id: UUID) -> Bool
    func numberOfItem() -> Int
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
    private weak var historyProvider: HistoryProvidable?
    private weak var countryProvider: CountryProvidable?
    private weak var travelProvider: TravelProvidable?
    
    init(countryProvider: CountryProvidable?, travelProvider: TravelProvidable?, historyProvider: HistoryProvidable?) {
        self.countryProvider = countryProvider
        self.travelProvider = travelProvider
        self.historyProvider = historyProvider
    }
    
    func createTravel(countryName: String, completion: @escaping (TravelItemViewModel?) -> Void) {
        travelProvider?.createTravel(countryName: countryName) { [weak self] (createdTravel) in
            guard let self = self,
                let historyProvider = self.historyProvider,
                let createdTravel = createdTravel else {
                completion(nil)
                return
            }
            
            let createdTravelItemViewModel = TravelItemViewModel(travel: createdTravel, historyProvider: historyProvider)
            self.travels.append(createdTravelItemViewModel)
            completion(createdTravelItemViewModel)
        }
        
    }
    
    func needFetchItems() {
        guard let fetchedTravels = travelProvider?.fetchTravels(),
            let historyProvider = self.historyProvider
            else { return }
        
        travels.removeAll()
        var newTravelItemViewModels: [TravelItemViewModel] = []
        
        fetchedTravels.forEach { travel in
            newTravelItemViewModels.append(TravelItemViewModel(travel: travel, historyProvider: historyProvider))
        }
        travels = newTravelItemViewModels
    }
    
    func cellForItemAt(id: UUID) -> TravelItemViewModel? {
        return travels.filter({ $0.id == id }).first
    }
    
    func updateTravel(countryName: String, id: UUID, title: String, memo: String?, startDate: Date?, endDate: Date?, coverImage: Data, budget: Double, exchangeRate: Double) -> Bool {
        let travelInfo = TravelInfo(countryName: countryName, id: id, title: title, memo: memo, startDate: startDate, endDate: endDate, coverImage: coverImage, budget: budget, exchangeRate: exchangeRate)
        
        guard let updatedTravel = travelProvider?.updateTravel(updatedTravelInfo: travelInfo),
            let indexToUpdate = travels.indices.filter({ travels[$0].id == updatedTravel.id }).first
            else { return false }

        travels[indexToUpdate].title = updatedTravel.title
        travels[indexToUpdate].memo = updatedTravel.memo
        travels[indexToUpdate].startDate = updatedTravel.startDate
        travels[indexToUpdate].endDate = updatedTravel.endDate
        travels[indexToUpdate].coverImage = updatedTravel.coverImage
        travels[indexToUpdate].budget = updatedTravel.budget
        travels[indexToUpdate].exchangeRate = updatedTravel.exchangeRate
        
        return true
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
