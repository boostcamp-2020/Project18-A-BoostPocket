//
//  TravelProfileVCTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/12/13.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class TravelProfileVCPresenterMock: TravelProfileVCPresenter {
    var onViewDidLoadCalled: Bool = false
    var onMemoLabelTappedCalled: Bool = false
    var onStartDateSelectedCalled: Bool = false
    
    func onViewDidLoad() {
        onViewDidLoadCalled = true
    }
    
    func onMemoLabelTapped() {
        onMemoLabelTappedCalled = true
    }
    
    func onStartDateSelected() {
        onStartDateSelectedCalled = true
    }
}

class TravelProfileVCTests: XCTestCase {
    let presenter = TravelProfileVCPresenterMock()
    
    func makeSUT() -> TravelProfileViewController {
        let storyboard = UIStoryboard(name: "TravelDetail", bundle: nil)
        guard let sut = storyboard.instantiateViewController(identifier: TravelProfileViewController.identifier) as? TravelProfileViewController else { return TravelProfileViewController() }
        
        sut.presenter = presenter
        sut.loadViewIfNeeded()
        return sut
    }
    
    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }
    
    func test_travelProfileVC_viewDidLoad() {
        let sut = makeSUT()
        sut.viewDidLoad()
        
        XCTAssertTrue(presenter.onViewDidLoadCalled)
    }
    
    func test_travelProfileVC_startDateSelected() {
        let sut = makeSUT()

        sut.startDateSelected(UIDatePicker())
        XCTAssertTrue(presenter.onStartDateSelectedCalled)
    }
}
