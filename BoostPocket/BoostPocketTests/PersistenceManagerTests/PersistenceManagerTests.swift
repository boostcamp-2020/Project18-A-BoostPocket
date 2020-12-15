//
//  PersistenceManagerTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
import CoreData
import NetworkManager
@testable import BoostPocket

class PersistenceManagerTests: XCTestCase {
    var persistenceManagerStub: PersistenceManagable!
    var countryInfo: CountryInfo!
    var travelInfo: TravelInfo!
    var historyInfo: HistoryInfo!
    var dataLoader: DataLoader?
    
    let id = UUID()
    let memo = ""
    let startDate = Date()
    let endDate = Date()
    let coverImage = Data()
    let budget = Double()
    let exchangeRate = 1.5
    let countryName = "대한민국"
    let lastUpdated = "2019-08-23".convertToDate()
    let flagImage = Data()
    let currencyCode = "KRW"
    let historyId = UUID()
    let identifier = "ko_KR"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        persistenceManagerStub = PersistenceManagerStub(dataLoader: dataLoader)
        countryInfo = CountryInfo(name: countryName, lastUpdated: lastUpdated, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode, identifier: identifier)
        travelInfo = TravelInfo(countryName: countryName, id: id, title: countryName, memo: memo, startDate: startDate, endDate: endDate, coverImage: coverImage, budget: budget, exchangeRate: exchangeRate)
        historyInfo = HistoryInfo(travelId: id, id: historyId, isIncome: false, title: "식당", memo: nil, date: Date(), category: .food, amount: Double(), image: nil, isPrepare: nil, isCard: nil)
        
        self.dataLoader = dataLoader
    }
    
    override func tearDownWithError() throws {
        persistenceManagerStub = nil
        countryInfo = nil
        travelInfo = nil
        historyInfo = nil
    }
    
    func test_persistenceManager_createCountriesWithAPIRequest_with_no_countries() {
        let createCountriesExpectation = XCTestExpectation(description: "Successfully Created Countries")
        
        var createCountriesResult: Bool = false
        persistenceManagerStub.createCountriesWithAPIRequest { result in
            createCountriesResult = result
            createCountriesExpectation.fulfill()
        }
        
        wait(for: [createCountriesExpectation], timeout: 1)
        XCTAssertTrue(createCountriesResult)
    }
    
    func test_persistenceManager_createCountriesWithAPIRequest_with_countries() {
        var createdCountry: Country?
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { country in
            createdCountry = country as? Country
        }
        
        XCTAssertNotNil(createdCountry)
        
        var createCountriesResult: Bool = false
        persistenceManagerStub.createCountriesWithAPIRequest { result in
            createCountriesResult = result
        }
        
        XCTAssertTrue(createCountriesResult)
    }
    
    func test_persistenceManager_setupCountries() {
        let requestExchangeRateExpectation = XCTestExpectation(description: "Successfully Reqested ExchangeRate")
        
        let url: String = "https://api.exchangeratesapi.io/latest?base=KRW"
        var exchangeRateData: ExchangeRate?
        dataLoader?.requestExchangeRate(url: url, completion: { result in
            switch result {
            case .success(let data):
                exchangeRateData = data
                XCTAssertNotNil(exchangeRateData)
                requestExchangeRateExpectation.fulfill()
            case .failure:
                break
            }
        })
        
        wait(for: [requestExchangeRateExpectation], timeout: 1)
        persistenceManagerStub.setupCountries(with: exchangeRateData!)
        
        XCTAssertTrue(persistenceManagerStub.count(request: Country.fetchRequest()) ?? 0 > 0)
    }
    
    func test_persistenceManager_filterCountries() {
        let identifiers = ["ko_KR", "ja_JP"]
        let rates = ["KRW": 1.0, "JPY": 0.0941570188]
        let expected = ["KR": "ko_KR", "JP": "ja_JP"]
        
        XCTAssertEqual(expected, persistenceManagerStub.filterCountries(identifiers, rates: rates))
    }
    
    func test_persistenceManager_createObject() {
        
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        var createdHistory: History?
        persistenceManagerStub.createObject(newObjectInfo: historyInfo) { createdObject in
            createdHistory = createdObject as? History
            XCTAssertNotNil(createdHistory)
        }
        
        let fetchedCounties = persistenceManagerStub.fetchAll(request: Country.fetchRequest())
        XCTAssertNotEqual(fetchedCounties, [])
        XCTAssertEqual(fetchedCounties.first, createdCountry)
        
        let fetchedTravels = persistenceManagerStub.fetchAll(request: Travel.fetchRequest())
        XCTAssertNotEqual(fetchedTravels, [])
        XCTAssertEqual(fetchedTravels.first, createdTravel)
        
        let fetchedHistories = persistenceManagerStub.fetchAll(request: History.fetchRequest())
        XCTAssertNotEqual(fetchedHistories, [])
        XCTAssertEqual(fetchedHistories.first, createdHistory)
        XCTAssertEqual(createdHistory?.travel, createdTravel)
    }
    
    func test_persistenceManager_isExchangeRateOutdated() {
        let dateString: String = "2020-11-30 10:20:00"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        let yeaterday: Date = dateFormatter.date(from: dateString)!
        let today = Date()
        
        XCTAssertFalse(persistenceManagerStub.isExchangeRateOutdated(lastUpdated: today))
        XCTAssertTrue(persistenceManagerStub.isExchangeRateOutdated(lastUpdated: yeaterday))
    }
    
    func test_persistenceManager_fetchAll() {
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        XCTAssertNotEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        XCTAssertNotEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
    }
    
//    func test_persistenceManager_fetch() {
//        var createdCountry: Country?
//
//        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
//            createdCountry = createdObject as? Country
//            XCTAssertNotNil(createdCountry)
//        }
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
//        fetchRequest.predicate = NSPredicate(format: "name == %@", countryInfo.name)
//
//        let fetchedCountry = persistenceManagerStub.fetch(fetchRequest) as? [Country]
//        XCTAssertNotNil(fetchedCountry)
//        XCTAssertEqual(fetchedCountry?.first, createdCountry)
//    }
    
    func test_persistenceManager_updateObject() {
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Travel Country")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        let newLastUpdated = "2020-12-25".convertToDate()
        let newExchagneRate = 12.0
        countryInfo = CountryInfo(name: countryName, lastUpdated: newLastUpdated, flagImage: flagImage, exchangeRate: newExchagneRate, currencyCode: currencyCode, identifier: identifier)
        
        travelInfo = TravelInfo(countryName: countryName, id: id, title: countryName, memo: "updated memo", startDate: startDate, endDate: endDate, coverImage: coverImage, budget: budget, exchangeRate: exchangeRate)
        
        let updateCountryExpectation = XCTestExpectation(description: "Successfully Updated Country")
        let updateTravelExpectation = XCTestExpectation(description: "Successfully Updated Travel")
        
        var updatedCountry: Country?
        persistenceManagerStub.updateObject(updatedObjectInfo: countryInfo) { dataModelProtocol in
            updatedCountry = dataModelProtocol as? Country
            XCTAssertNotNil(updatedCountry)
            updateCountryExpectation.fulfill()
        }
        
        var updatedTravel: Travel?
        persistenceManagerStub.updateObject(updatedObjectInfo: travelInfo) { dataModelProtocol in
            updatedTravel = dataModelProtocol as? Travel
            XCTAssertNotNil(updatedTravel)
            updateTravelExpectation.fulfill()
        }
        
        wait(for: [updateCountryExpectation, updateTravelExpectation], timeout: 5.0)
        
        XCTAssertEqual(createdCountry?.lastUpdated, newLastUpdated)
        XCTAssertEqual(createdCountry?.exchangeRate, newExchagneRate)
        
        XCTAssertEqual(createdTravel?.memo, "updated memo")
    }
    
    func test_persistenceManager_delete() {
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Travel Country")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()).first, createdCountry)
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()).first, createdTravel)
        
        XCTAssertTrue(persistenceManagerStub.delete(deletingObject: createdTravel))
        XCTAssertTrue(persistenceManagerStub.delete(deletingObject: createdCountry))
        
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Country.fetchRequest()), [])
        XCTAssertEqual(persistenceManagerStub.fetchAll(request: Travel.fetchRequest()), [])
    }
    
    func test_persistenceManager_count() {
        XCTAssertEqual(persistenceManagerStub.count(request: Country.fetchRequest()), 0)
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 0)
        
        let countryExpectation = XCTestExpectation(description: "Successfully Created Country")
        var createdCountry: Country?
        
        persistenceManagerStub.createObject(newObjectInfo: countryInfo) { (createdObject) in
            createdCountry = createdObject as? Country
            XCTAssertNotNil(createdCountry)
            countryExpectation.fulfill()
        }
        
        let travelExpectation = XCTestExpectation(description: "Successfully Travel Country")
        var createdTravel: Travel?
        
        persistenceManagerStub.createObject(newObjectInfo: travelInfo) { (createdObject) in
            createdTravel = createdObject as? Travel
            XCTAssertNotNil(createdTravel)
            travelExpectation.fulfill()
        }
        
        wait(for: [countryExpectation, travelExpectation], timeout: 5.0)
        
        XCTAssertEqual(persistenceManagerStub.count(request: Country.fetchRequest()), 1)
        XCTAssertEqual(persistenceManagerStub.count(request: Travel.fetchRequest()), 1)
    }
}
