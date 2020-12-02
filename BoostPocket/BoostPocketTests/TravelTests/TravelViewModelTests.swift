//
//  TravelViewModelTests.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import NetworkManager
@testable import BoostPocket

class TravelViewModelTests: XCTestCase {
    
    var travelListViewModel: TravelListPresentable!
    var persistenceManagerStub: PersistenceManagable!
    var countryProvider: CountryProvidable!
    var travelProvider: TravelProvidable!
    var historyProvider: HistoryProvider!
    var dataLoader: DataLoader?
    let countriesExpectation = XCTestExpectation(description: "Successfully Created Countries")
    
    let id = UUID()
    let title = "test title"
    let memo = "memo"
    let budget = 3.29
    let coverImage = Data()
    let startDate = Date()
    let endDate = Date()
    let exchangeRate = 12.1
    let countryName = "대한민국"
    let lastUpdated = "2019-08-23".convertToDate()
    let flagImage = Data()
    let currencyCode = "KRW"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        
        persistenceManagerStub.createCountriesWithAPIRequest { [weak self] (result) in
            if result {
                self?.countriesExpectation.fulfill()
            }
        }
        
        countryProvider = CountryProvider(persistenceManager: persistenceManagerStub)
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
        historyProvider = HistoryProvider(persistenceManager: persistenceManagerStub)
        
        travelListViewModel = TravelListViewModel(countryProvider: countryProvider, travelProvider: travelProvider, historyProvider: historyProvider)

        self.dataLoader = dataLoader
    }
    
    override func tearDownWithError() throws {
        travelListViewModel = nil
        travelProvider = nil
        persistenceManagerStub = nil
    }
    
    func test_travelItemViewModel_createInstance() throws {
        wait(for: [countriesExpectation], timeout: 5.0)
        let fetchedCountries = countryProvider.fetchCountries()
        let firstCountry = fetchedCountries.first
        XCTAssertNotNil(fetchedCountries)
        XCTAssertNotNil(firstCountry)
        
        let travel = TravelStub(id: id, title: title, memo: memo, exchangeRate: exchangeRate,
                                budget: budget, coverImage: coverImage, startDate: startDate,
                                endDate: endDate, country: firstCountry)
        let travelItemViewModel = TravelItemViewModel(travel: travel, historyProvider: historyProvider)
        
        XCTAssertNotNil(travel)
        XCTAssertEqual(travelItemViewModel.id, id)
        XCTAssertEqual(travelItemViewModel.title, title)
        XCTAssertEqual(travelItemViewModel.memo, memo)
        XCTAssertEqual(travelItemViewModel.exchangeRate, exchangeRate)
        XCTAssertEqual(travelItemViewModel.budget, budget)
        XCTAssertEqual(travelItemViewModel.coverImage, coverImage)
        XCTAssertEqual(travelItemViewModel.startDate, startDate)
        XCTAssertEqual(travelItemViewModel.endDate, endDate)
        XCTAssertEqual(travelItemViewModel.currencyCode, firstCountry?.currencyCode)
        XCTAssertEqual(travelItemViewModel.flagImage, firstCountry?.flagImage)
        XCTAssertEqual(travelItemViewModel.countryName, firstCountry?.name)
    }
    
    func test_travelListViewModel_createTravel() {
        wait(for: [countriesExpectation], timeout: 5.0)
        
        let expectation = XCTestExpectation(description: "Successfully Created TravelItemViewModel")
        var createdTravelItemViewModel: TravelItemViewModel?
        
        travelListViewModel.createTravel(countryName: countryName) { (travelItemViewModel) in
            createdTravelItemViewModel = travelItemViewModel
            XCTAssertNotNil(createdTravelItemViewModel)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    
        XCTAssertEqual(createdTravelItemViewModel?.title, countryName)
        XCTAssertEqual(createdTravelItemViewModel?.countryName, countryName)
        XCTAssertEqual(createdTravelItemViewModel?.currencyCode, currencyCode)
        XCTAssertEqual(createdTravelItemViewModel?.budget, Double())
        XCTAssertNotNil(createdTravelItemViewModel?.exchangeRate)
        XCTAssertNotNil(createdTravelItemViewModel?.coverImage)
        XCTAssertNotNil(createdTravelItemViewModel?.flagImage)
        XCTAssertNil(createdTravelItemViewModel?.startDate)
        XCTAssertNil(createdTravelItemViewModel?.endDate)
        XCTAssertNil(createdTravelItemViewModel?.memo)
    }
    
    func test_travelListViewModel_needFetchItems() {
        wait(for: [countriesExpectation], timeout: 5.0)
        
        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            createdTravel = travel
            XCTAssertNotNil(createdTravel)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        travelListViewModel.needFetchItems()
        let firstTravel = travelListViewModel.travels.first
        
        XCTAssertNotNil(firstTravel)
        XCTAssertEqual(travelListViewModel.travels.count, 1)
        XCTAssertEqual(firstTravel?.id, createdTravel?.id)
    }

    func test_travelListViewModel_numberOfItem() {
        wait(for: [countriesExpectation], timeout: 5.0)
        
        let expectation = XCTestExpectation(description: "Successfully Created TravelItemViewModel")
        
        travelListViewModel.createTravel(countryName: countryName) { (travelItemViewModel) in
            XCTAssertNotNil(travelItemViewModel)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
                
        XCTAssertEqual(travelListViewModel.numberOfItem(), 1)
    }
    
    func test_travelListViewModel_deleteTravel() {
        wait(for: [countriesExpectation], timeout: 5.0)
        
        let expectation = XCTestExpectation(description: "Successfully Created TravelItemViewModel")
        var createdItemViewModel: TravelItemViewModel?
        
        travelListViewModel.createTravel(countryName: countryName) { (travelItemViewModel) in
            XCTAssertNotNil(travelItemViewModel)
            createdItemViewModel = travelItemViewModel
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        let id = createdItemViewModel?.id
        XCTAssertTrue(travelListViewModel.deleteTravel(id: id ?? UUID()))
    }

    func test_travelListViewModel_updateTravel() {
        wait(for: [countriesExpectation], timeout: 5.0)
        
        let expectation = XCTestExpectation(description: "Successfully Created TravelItemViewModel")
        var createdItemViewModel: TravelItemViewModel?
        
        travelListViewModel.createTravel(countryName: countryName) { (travelItemViewModel) in
            XCTAssertNotNil(travelItemViewModel)
            createdItemViewModel = travelItemViewModel
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(travelListViewModel.updateTravel(countryName: countryName, id: createdItemViewModel?.id ?? UUID(), title: countryName, memo: createdItemViewModel?.memo ?? "", startDate: createdItemViewModel?.startDate ?? Date(), endDate: createdItemViewModel?.startDate ?? Date(), coverImage: createdItemViewModel?.coverImage ?? Data(), budget: createdItemViewModel?.budget ?? Double(), exchangeRate: createdItemViewModel?.exchangeRate ?? Double()))
    }
}
