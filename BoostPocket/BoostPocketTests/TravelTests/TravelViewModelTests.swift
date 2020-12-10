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
        var createdTravelItemViewModel: TravelItemViewModel?
        createdTravelItemViewModel = createTravelItemViewModelForTests()
    
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
    
    func test_travelItemViewModel_getTotalIncome() {
        var createdHistory: HistoryItemViewModel?
        let travelItemViewModel = createTravelItemViewModelForTests()
        
        XCTAssertNotNil(travelItemViewModel)
        
        let historyExpectation = XCTestExpectation(description: "Successfully Created History")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: true, title: "income history", memo: nil, date: Date(), image: Data(), amount: 12000, category: .income, isPrepare: false, isCard: false) { historyItemViewModel in
            XCTAssertNotNil(historyItemViewModel)
            createdHistory = historyItemViewModel
            historyExpectation.fulfill()
        }
        
        wait(for: [historyExpectation], timeout: 5.0)
        
        XCTAssertEqual(createdHistory?.amount, travelItemViewModel?.getTotalIncome())
    }
    
    func test_travelItemViewModel_getTotalExpense() {
        var createdHistory: HistoryItemViewModel?
        let travelItemViewModel = createTravelItemViewModelForTests()
        
        XCTAssertNotNil(travelItemViewModel)
        
        let historyExpectation = XCTestExpectation(description: "Successfully Created History")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "expense history", memo: nil, date: Date(), image: Data(), amount: 12000, category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            XCTAssertNotNil(historyItemViewModel)
            createdHistory = historyItemViewModel
            historyExpectation.fulfill()
        }
        
        wait(for: [historyExpectation], timeout: 5.0)
        
        XCTAssertEqual(createdHistory?.amount, travelItemViewModel?.getTotalExpense())
    }
    
    func test_travelItemViewModel_expensePercentage() {
        var createdExpenseHistory: HistoryItemViewModel?
        var createdIncomeHistory: HistoryItemViewModel?
        let travelItemViewModel = createTravelItemViewModelForTests()
        
        XCTAssertNotNil(travelItemViewModel)
        
        let expenseExpectation = XCTestExpectation(description: "Successfully Created ExpenseHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "expense history", memo: nil, date: Date(), image: Data(), amount: 12000, category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            createdExpenseHistory = historyItemViewModel
            XCTAssertNotNil(createdExpenseHistory)
            expenseExpectation.fulfill()
        }
        
        wait(for: [expenseExpectation], timeout: 5.0)
        
        let incomeExpectation = XCTestExpectation(description: "Successfully Created IncomeHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: true, title: "income history", memo: nil, date: Date(), image: Data(), amount: 24000, category: .income, isPrepare: false, isCard: false) { historyItemViewModel in
            createdIncomeHistory = historyItemViewModel
            XCTAssertNotNil(createdIncomeHistory)
            incomeExpectation.fulfill()
        }
        
        wait(for: [incomeExpectation], timeout: 5.0)
        
        let percentage = createdExpenseHistory!.amount / createdIncomeHistory!.amount
        XCTAssertEqual(Float(percentage), travelItemViewModel?.expensePercentage)
    }
    
    /*
    func test_travelItemViewModel_expensePercentage_expense_is_not_a_number() {
        var createdExpenseHistory: HistoryItemViewModel?
        var createdIncomeHistory: HistoryItemViewModel?
        let travelItemViewModel = createTravelItemViewModelForTests()
        
        XCTAssertNotNil(travelItemViewModel)
        
        let expenseExpectation = XCTestExpectation(description: "Successfully Created ExpenseHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "expense history", memo: nil, date: Date(), image: Data(), amount: Double.nan, category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            createdExpenseHistory = historyItemViewModel
            XCTAssertNotNil(createdExpenseHistory)
            expenseExpectation.fulfill()
        }
        
        wait(for: [expenseExpectation], timeout: 5.0)
        
        let incomeExpectation = XCTestExpectation(description: "Successfully Created IncomeHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: true, title: "income history", memo: nil, date: Date(), image: Data(), amount: 24000, category: .income, isPrepare: false, isCard: false) { historyItemViewModel in
            createdIncomeHistory = historyItemViewModel
            XCTAssertNotNil(createdIncomeHistory)
            incomeExpectation.fulfill()
        }
        
        wait(for: [incomeExpectation], timeout: 5.0)
        
        XCTAssertEqual(1.0, travelItemViewModel?.expensePercentage)
    }
    
    func test_travelItemViewModel_expensePercentage_income_is_not_a_number() {
        var createdExpenseHistory: HistoryItemViewModel?
        var createdIncomeHistory: HistoryItemViewModel?
        let travelItemViewModel = createTravelItemViewModelForTests()
        
        XCTAssertNotNil(travelItemViewModel)
        
        let expenseExpectation = XCTestExpectation(description: "Successfully Created ExpenseHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "expense history", memo: nil, date: Date(), image: Data(), amount: 12000, category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            createdExpenseHistory = historyItemViewModel
            XCTAssertNotNil(createdExpenseHistory)
            expenseExpectation.fulfill()
        }
        
        wait(for: [expenseExpectation], timeout: 5.0)
        
        let incomeExpectation = XCTestExpectation(description: "Successfully Created IncomeHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: true, title: "income history", memo: nil, date: Date(), image: Data(), amount: Double.nan, category: .income, isPrepare: false, isCard: false) { historyItemViewModel in
            createdIncomeHistory = historyItemViewModel
            XCTAssertNotNil(createdIncomeHistory)
            incomeExpectation.fulfill()
        }
        
        wait(for: [incomeExpectation], timeout: 5.0)
        
        XCTAssertEqual(0.0, travelItemViewModel?.expensePercentage)
    }
     */
    
    func test_travelItemViewModel_getHistoryDictionary() {
        var firstExpenseHistory: HistoryItemViewModel?
        var secondExpenseHistory: HistoryItemViewModel?
        let travelItemViewModel = createTravelItemViewModelForTests()
        
        XCTAssertNotNil(travelItemViewModel)
        
        let etcExpectation = XCTestExpectation(description: "Successfully Created ExpenseHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "expense history", memo: nil, date: Date(), image: Data(), amount: 12000, category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            firstExpenseHistory = historyItemViewModel
            XCTAssertNotNil(firstExpenseHistory)
            etcExpectation.fulfill()
        }
        
        wait(for: [etcExpectation], timeout: 5.0)
        
        let hotelExpectation = XCTestExpectation(description: "Successfully Created IncomeHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "accommodation history", memo: nil, date: Date(), image: Data(), amount: 50000, category: .accommodation, isPrepare: false, isCard: true) { historyItemViewModel in
            secondExpenseHistory = historyItemViewModel
            XCTAssertNotNil(secondExpenseHistory)
            hotelExpectation.fulfill()
        }
        
        wait(for: [hotelExpectation], timeout: 5.0)
        
        let comparativeGroup = [firstExpenseHistory?.category: firstExpenseHistory?.amount, secondExpenseHistory?.category: secondExpenseHistory?.amount]
        XCTAssertEqual(comparativeGroup, travelItemViewModel?.getHistoriesDictionary(from: travelItemViewModel!.histories))
    }
    
    func test_travelItemViewModel_mostFrequentCategory() {
        var firstExpenseHistory: HistoryItemViewModel?
        var secondExpenseHistory: HistoryItemViewModel?
        let travelItemViewModel = createTravelItemViewModelForTests()
        
        XCTAssertNotNil(travelItemViewModel)
        
        let etcExpectation = XCTestExpectation(description: "Successfully Created ExpenseHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "expense history", memo: nil, date: Date(), image: Data(), amount: 12000, category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            firstExpenseHistory = historyItemViewModel
            XCTAssertNotNil(firstExpenseHistory)
            etcExpectation.fulfill()
        }
        
        wait(for: [etcExpectation], timeout: 5.0)
        
        let hotelExpectation = XCTestExpectation(description: "Successfully Created IncomeHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "accommodation history", memo: nil, date: Date(), image: Data(), amount: 50000, category: .accommodation, isPrepare: false, isCard: true) { historyItemViewModel in
            secondExpenseHistory = historyItemViewModel
            XCTAssertNotNil(secondExpenseHistory)
            hotelExpectation.fulfill()
        }
        
        let percentage = round((secondExpenseHistory!.amount / travelItemViewModel!.getTotalExpense()) * 1000) / 10
        
        wait(for: [hotelExpectation], timeout: 5.0)
        XCTAssertEqual(secondExpenseHistory?.category, travelItemViewModel?.mostFrequentCategory.0)
        XCTAssertEqual(percentage, travelItemViewModel?.mostFrequentCategory.1)
    }
    
    /*
    func test_travelItemViewModel_mostFrequentCategory_amount_is_not_a_number() {
        var firstExpenseHistory: HistoryItemViewModel?
        var secondExpenseHistory: HistoryItemViewModel?
        let travelItemViewModel = createTravelItemViewModelForTests()
        
        XCTAssertNotNil(travelItemViewModel)
        
        let etcExpectation = XCTestExpectation(description: "Successfully Created ExpenseHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "expense history", memo: nil, date: Date(), image: Data(), amount: 12000, category: .etc, isPrepare: false, isCard: false) { historyItemViewModel in
            firstExpenseHistory = historyItemViewModel
            XCTAssertNotNil(firstExpenseHistory)
            etcExpectation.fulfill()
        }
        
        wait(for: [etcExpectation], timeout: 5.0)
        
        let hotelExpectation = XCTestExpectation(description: "Successfully Created IncomeHistory")
        
        travelItemViewModel?.createHistory(id: travelItemViewModel?.id ?? id, isIncome: false, title: "accommodation history", memo: nil, date: Date(), image: Data(), amount: Double.nan, category: .accommodation, isPrepare: false, isCard: true) { historyItemViewModel in
            secondExpenseHistory = historyItemViewModel
            XCTAssertNotNil(secondExpenseHistory)
            hotelExpectation.fulfill()
        }
        
        wait(for: [hotelExpectation], timeout: 5.0)
        XCTAssertEqual(secondExpenseHistory?.category, travelItemViewModel?.mostFrequentCategory.0)
        XCTAssertEqual(100.0, travelItemViewModel?.mostFrequentCategory.1)
    }
     */

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
    
    private func createTravelItemViewModelForTests() -> TravelItemViewModel? {
        wait(for: [countriesExpectation], timeout: 5.0)
        
        let fetchedCountries = countryProvider.fetchCountries()
        let firstCountry = fetchedCountries.first
        XCTAssertNotNil(fetchedCountries)
        XCTAssertNotNil(firstCountry)
        
        let travelExpectation = XCTestExpectation(description: "Successfully Created Travel")
        var createdTravel: Travel?
        var createdTravelItemViewModel: TravelItemViewModel?
        
        travelProvider.createTravel(countryName: countryName) { travel in
            XCTAssertNotNil(travel)
            createdTravel = travel
            createdTravelItemViewModel = TravelItemViewModel(travel: createdTravel!, historyProvider: self.historyProvider)
            travelExpectation.fulfill()
        }
        
        wait(for: [travelExpectation], timeout: 5.0)
        return createdTravelItemViewModel
    }
}
