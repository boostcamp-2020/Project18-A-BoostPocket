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
    var country: Country!
    var dataLoader: DataLoader?
    
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
        countryProvider = CountryProvider(persistenceManager: persistenceManagerStub)
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
        travelListViewModel = TravelListViewModel(countryProvider: countryProvider, travelProvider: travelProvider)
        countryProvider.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode) { _ in }

        self.dataLoader = dataLoader
    }
    
    override func tearDownWithError() throws {
        travelListViewModel = nil
        travelProvider = nil
        country = nil
        countryProvider = nil
        persistenceManagerStub = nil
    }
    
    func test_travelItemViewModel_createInstance() throws {
        let travel = TravelStub(id: id, title: title, memo: memo, exchangeRate: exchangeRate,
                                budget: budget, coverImage: coverImage, startDate: startDate,
                                endDate: endDate, country: country)
        let travelItemViewModel = TravelItemViewModel(travel: travel)
        
        XCTAssertNotNil(travel)
        XCTAssertEqual(travelItemViewModel.id, id)
        XCTAssertEqual(travelItemViewModel.title, title)
        XCTAssertEqual(travelItemViewModel.memo, memo)
        XCTAssertEqual(travelItemViewModel.exchangeRate, exchangeRate)
        XCTAssertEqual(travelItemViewModel.budget, budget)
        XCTAssertEqual(travelItemViewModel.coverImage, coverImage)
        XCTAssertEqual(travelItemViewModel.startDate, startDate)
        XCTAssertEqual(travelItemViewModel.endDate, endDate)
        XCTAssertEqual(travelItemViewModel.currencyCode, country?.currencyCode)
        XCTAssertEqual(travelItemViewModel.flagImage, country?.flagImage)
        XCTAssertEqual(travelItemViewModel.countryName, country?.name)
    }
    
    func test_travelListViewModel_createTravel() {
        let expectation = XCTestExpectation(description: "Successfully Created TravelItemViewModel")
        
        travelListViewModel.createTravel(countryName: countryName) { (travelItemViewModel) in
            XCTAssertNotNil(travelItemViewModel)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    
        let createdTravelItemViewModel = travelListViewModel.travels.first
        XCTAssertNotNil(createdTravelItemViewModel)
        XCTAssertEqual(createdTravelItemViewModel?.title, countryName)
        XCTAssertEqual(createdTravelItemViewModel?.countryName, countryName)
        XCTAssertEqual(createdTravelItemViewModel?.currencyCode, currencyCode)
        XCTAssertEqual(createdTravelItemViewModel?.budget, Double())
        XCTAssertNotNil(createdTravelItemViewModel?.exchangeRate)
        XCTAssertNil(createdTravelItemViewModel?.startDate)
        XCTAssertNil(createdTravelItemViewModel?.endDate)
        XCTAssertNil(createdTravelItemViewModel?.memo)
        XCTAssertNotNil(createdTravelItemViewModel?.coverImage)
        XCTAssertNotNil(createdTravelItemViewModel?.flagImage)
    }
    
    func test_travelListViewModel_needFetchItems() {
        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            XCTAssertNotNil(travel)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        travelListViewModel.needFetchItems()
        let firstTravel = travelListViewModel.travels.first
        
        XCTAssertNotNil(firstTravel)
        XCTAssertEqual(travelListViewModel.travels.count, 1)
        XCTAssertEqual(firstTravel?.title, countryName)
    }

    func test_travelListViewModel_numberOfItem() {
        let expectation = XCTestExpectation(description: "Successfully Created TravelItemViewModel")
        
        travelListViewModel.createTravel(countryName: countryName) { (travelItemViewModel) in
            XCTAssertNotNil(travelItemViewModel)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
                
        XCTAssertEqual(travelListViewModel.numberOfItem(), 1)
    }
    
    func test_travelListViewModel_deleteTravel() {
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
