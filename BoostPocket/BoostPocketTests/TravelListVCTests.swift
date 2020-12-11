//
//  TravelListVCTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/12/12.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class TravelListVCPresenterMock: TravelListVCPresenter {
    private(set) var onViewDidLoadCalled = false
    private(set) var onLayoutButtonTappedCalled = false
    private(set) var onDefaultLayoutButtonTappedCalled = false
    private(set) var onSquareLayoutButtonTappedCalled = false
    private(set) var onRectangleLayoutButtonTappedCalled = false
    
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
    
    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

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
    }
    
    func test_travelListVC_layoutButtonTapped_squareLayout() {
        let sut = makeSUT()
        
        sut.layoutButtonTapped(sut.layoutButtons[1])
        XCTAssertTrue(presenter.onSquareLayoutButtonTappedCalled)
    }
    
    func test_travelListVC_layoutButtonTapped_rectangleLayout() {
        let sut = makeSUT()
        
        sut.layoutButtonTapped(sut.layoutButtons[2])
        XCTAssertTrue(presenter.onRectangleLayoutButtonTappedCalled)
    }
}
