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
    var travelProvider: TravelProvidable!
    var dataLoader: DataLoader?
    let countriesExpectation = XCTestExpectation(description: "Successfully Created Countries")
    let countryName = "대한민국"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        
        persistenceManagerStub.createCountriesWithAPIRequest { [weak self] (result) in
            if result {
                self?.countriesExpectation.fulfill()
            }
        }
        
        travelProvider = TravelProvider(persistenceManager: persistenceManagerStub)
        self.dataLoader = dataLoader
    }
    
    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        travelProvider = nil
    }

    func test_travelProvider_createTravel() {
        wait(for: [countriesExpectation], timeout: 5.0)
        
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
        wait(for: [countriesExpectation], timeout: 5.0)
        
        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            createdTravel = travel
            XCTAssertNotNil(createdTravel)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        
        let fetchedTravels = travelProvider.fetchTravels()
        let firstTravel = travelProvider.fetchTravels().first
        
        XCTAssertNotEqual(fetchedTravels, [])
        XCTAssertNotNil(firstTravel)
        XCTAssertEqual(firstTravel, createdTravel)
    }

    func test_travelPrpvider_updateTravel() {
        wait(for: [countriesExpectation], timeout: 5.0)
        
        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            XCTAssertNotNil(travel)
            createdTravel = travel
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        
        let travelInfo = TravelInfo(countryName: countryName, id: createdTravel?.id ?? UUID(), title: "updated title", memo: createdTravel?.memo ?? "", startDate: createdTravel?.startDate ?? Date(), endDate: createdTravel?.endDate ?? Date(), coverImage: createdTravel?.coverImage ?? Data(), budget: createdTravel?.budget ?? Double(), exchangeRate: createdTravel?.exchangeRate ?? Double())
        
        let updateTravelExpectation = XCTestExpectation(description: "Successfully Updated Travel")
        var updatedTravel: Travel?
        
        travelProvider.updateTravel(updatedTravelInfo: travelInfo) { travel in
            updatedTravel = travel
            XCTAssertNotNil(updatedTravel)
            updateTravelExpectation.fulfill()
        }
        
        wait(for: [updateTravelExpectation], timeout: 5.0)
        
        XCTAssertEqual(updatedTravel?.title, "updated title")
        XCTAssertEqual(createdTravel, updatedTravel)
        XCTAssertEqual(travelProvider.fetchTravels().first, createdTravel)
    }
    
    func test_travelProvider_deleteTravel() {
        wait(for: [countriesExpectation], timeout: 5.0)
        
        XCTAssertEqual(travelProvider.fetchTravels(), [])
        
        let expectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        travelProvider.createTravel(countryName: countryName) { (travel) in
            createdTravel = travel
            XCTAssertNotNil(createdTravel)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        let isDeleted = travelProvider.deleteTravel(id: createdTravel?.id ?? UUID())
        XCTAssertTrue(isDeleted)
        XCTAssertEqual(travelProvider.fetchTravels(), [])
    }
}
