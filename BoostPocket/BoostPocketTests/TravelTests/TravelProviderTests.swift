//
//  TravelProviderTests.swift
//  BoostPocketTests
//
//  Created by 이승진 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import NetworkManager
@testable import BoostPocket

class TravelProviderTests: XCTestCase {
    
    var persistenceManagerStub: PersistenceManagable!
    var countryProvider: CountryProvidable!
    var travelProvider: TravelProvidable!
    var country: Country!
    var dataLoader: DataLoader?

    let countryName = "대한민국"
    let lastUpdated = "2019-08-23".convertToDate()
    let flagImage = Data()
    let exchangeRate = 1.5
    let currencyCode = "test code"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        countryProvider = CountryProvider(persistenceManager: persistenceManagerStub)
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
        countryProvider.createCountry(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode) { _ in }
        
        self.dataLoader = dataLoader
    }
    
    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryProvider = nil
        travelProvider = nil
    }

    func test_travelProvider_createTravel() {
        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            XCTAssertNotNil(travel)
            createdTravel = travel
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(createdTravel?.title, countryName)
        XCTAssertEqual(createdTravel?.country?.name, countryName)
    }

    func test_travelProvider_fetchTravels() {
        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            XCTAssertNotNil(travel)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        
        let fetchedTravels = travelProvider.fetchTravels()
        XCTAssertNotEqual(fetchedTravels, [])

        let firstTravel = travelProvider.fetchTravels().first
        XCTAssertNotNil(firstTravel)
        XCTAssertEqual(firstTravel?.title, countryName)
        XCTAssertEqual(firstTravel?.exchangeRate, exchangeRate)
    }

    func test_travelPrpvider_updateTravel() {
        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            XCTAssertNotNil(travel)
            createdTravel = travel
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        
        let travelInfo = TravelInfo(countryName: countryName, id: createdTravel?.id ?? UUID(), title: "updated title", memo: createdTravel?.memo ?? "", startDate: createdTravel?.startDate ?? Date(), endDate: createdTravel?.endDate ?? Date(), coverImage: createdTravel?.coverImage ?? Data(), budget: createdTravel?.budget ?? Double(), exchangeRate: createdTravel?.exchangeRate ?? Double())
        let updatedTravel = travelProvider.updateTravel(updatedTravelInfo: travelInfo)
        
        XCTAssertNotNil(updatedTravel)
        XCTAssertEqual(updatedTravel?.title, "updated title")
        XCTAssertEqual(createdTravel, updatedTravel)
        XCTAssertEqual(travelProvider.fetchTravels().first, createdTravel)
    }
    
    func test_travelProvider_deleteTravel() {
        XCTAssertEqual(travelProvider.fetchTravels(), [])

        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            XCTAssertNotNil(travel)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        let fetchedTravels = travelProvider.fetchTravels()
        XCTAssertNotEqual(fetchedTravels, [])

        let fetchedTravel = travelProvider.fetchTravels().first
        XCTAssertNotNil(fetchedTravel)

        let isDeleted = travelProvider.deleteTravel(id: fetchedTravel?.id ?? UUID())
        XCTAssertTrue(isDeleted)
        XCTAssertEqual(travelProvider.fetchTravels(), [])
    }
}
