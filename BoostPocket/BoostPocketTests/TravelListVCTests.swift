//
//  TravelListVCTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/12/12.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import NetworkManager
@testable import BoostPocket

class TravelListVCPresenterMock: TravelListVCPresenter {
    var onViewDidLoadCalled: Bool = false
    var onLayoutButtonTappedCalled: Bool = false
    var onDefaultLayoutButtonTappedCalled: Bool = false
    var onSquareLayoutButtonTappedCalled: Bool = false
    var onRectangleLayoutButtonTappedCalled: Bool = false
    var onUpdateTravelCalled: Bool = false
    
    func onViewDidLoad() {
        onViewDidLoadCalled = true
    }
    
    func onLayoutButtonTapped() {
        onLayoutButtonTappedCalled = true
    }
    
    func onDefaultLayoutButtonTapped() {
        onDefaultLayoutButtonTappedCalled = true
    }
    
    func onSquareLayoutButtonTapped() {
        onSquareLayoutButtonTappedCalled = true
    }
    
    func onRectangleLayoutButtonTapped() {
        onRectangleLayoutButtonTappedCalled = true
    }

    func onUpdateTravel() {
        onUpdateTravelCalled = true
    }
}

class TravelListVCTests: XCTestCase {
    let presenter = TravelListVCPresenterMock()
    
    func makeSUT() -> TravelListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let sut = storyboard.instantiateViewController(identifier: TravelListViewController.identifier) as? TravelListViewController else { return TravelListViewController() }
        
        sut.presenter = presenter
        sut.loadViewIfNeeded()
        return sut
    }
    
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

    func test_travelListVC_viewDidLoad() {
        let sut = makeSUT()
        
        sut.viewDidLoad()
        XCTAssertTrue(presenter.onViewDidLoadCalled)
    }
    
    func test_travelListVC_layoutButtonTapped() {
        let sut = makeSUT()
        
        sut.layoutButtonTapped(UIButton())
        XCTAssertTrue(presenter.onLayoutButtonTappedCalled)
    }
    
    func test_travelListVC_layoutButtonTapped_defaultLayout() {
        let sut = makeSUT()
        
        sut.layoutButtonTapped(sut.layoutButtons[0])
        XCTAssertTrue(presenter.onDefaultLayoutButtonTappedCalled)
        XCTAssertEqual(sut.layout, Layout.defaultLayout)
    }
    
    func test_travelListVC_layoutButtonTapped_squareLayout() {
        let sut = makeSUT()
        
        sut.layoutButtonTapped(sut.layoutButtons[1])
        XCTAssertTrue(presenter.onSquareLayoutButtonTappedCalled)
        XCTAssertEqual(sut.layout, Layout.squareLayout)
    }
    
    func test_travelListVC_layoutButtonTapped_rectangleLayout() {
        let sut = makeSUT()
        
        sut.layoutButtonTapped(sut.layoutButtons[2])
        XCTAssertTrue(presenter.onRectangleLayoutButtonTappedCalled)
        XCTAssertEqual(sut.layout, Layout.rectangleLayout)
    }
    
    func test_travelListVC_updateTravelFail() {
        let sut = makeSUT()
        
        let updateTravelExpectation = XCTestExpectation(description: "Successfully Updated Travel")
        
        sut.updateTravel { result in
            XCTAssertFalse(result)
            updateTravelExpectation.fulfill()
        }
        
        wait(for: [updateTravelExpectation], timeout: 1)
        XCTAssertTrue(presenter.onUpdateTravelCalled)
    }
    
    func test_travelListVC_updateTravelPass() {
        // create countries
        wait(for: [countriesExpectation], timeout: 5)
        
        let sut = makeSUT()
        sut.travelListViewModel = travelListViewModel
        
        // create travel
        let fetchedCountries = countryProvider.fetchCountries()
        let firstCountry = fetchedCountries.first
        XCTAssertNotNil(fetchedCountries)
        XCTAssertNotNil(firstCountry)
        
        let travelExpectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravelItemViewModel: TravelItemViewModel?
        
        sut.travelListViewModel?.createTravel(countryName: countryName) { travelItemViewModel in
            createdTravelItemViewModel = travelItemViewModel
            XCTAssertNotNil(createdTravelItemViewModel)
            travelExpectation.fulfill()
        }

        wait(for: [travelExpectation], timeout: 5)
        
        // update travel
        let updateTravelExpectation = XCTestExpectation(description: "Successfully Updated Travel")
        
        sut.updateTravel(id: createdTravelItemViewModel?.id, newTitle: "new title", newMemo: "new memo", newStartDate: startDate, newEndDate: endDate, newCoverImage: coverImage, newBudget: 0, newExchangeRate: exchangeRate) { result in
            if result {
                XCTAssertTrue(result)
                updateTravelExpectation.fulfill()
            }
        }
        
        wait(for: [updateTravelExpectation], timeout: 4)
        XCTAssertTrue(presenter.onUpdateTravelCalled)
        
    }
}
