//
//  HistoryListVCTests.swift
//  BoostPocketTests
//
//  Created by sihyung you on 2020/12/13.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class HistoryListVCPresenterMock: HistoryListVCPresenter {
    var onViewDidLoadCalled: Bool = false
    var onFloatingActionButtonTappedCalled: Bool = false
    var onCloseFloatingActionsCalled: Bool = false
    var onOpenFloatingActionsCalled: Bool = false
    var onRotateFloatingActionButtonCalled: Bool = false
    var onAnimationDoneCalled: Bool = false
    
    func onViewDidLoad() {
        onViewDidLoadCalled = true
    }
    
    func onFloatingActionButtonTapped() {
        onFloatingActionButtonTappedCalled = true
    }
    
    func onCloseFloatingActions() {
        onCloseFloatingActionsCalled = true
    }
    
    func onOpenFloatingActions() {
        onOpenFloatingActionsCalled = true
    }
    
    func onRotateFloatingActionButton() {
        onRotateFloatingActionButtonCalled = true
    }
    
    func onAnimationDone() {
        onAnimationDoneCalled = true
    }
}

class HistoryListVCTests: XCTestCase {
    let presenter = HistoryListVCPresenterMock()
    
    func makeSUT() -> HistoryListViewController {
        let storyboard = UIStoryboard(name: "TravelDetail", bundle: nil)
        guard let sut = storyboard.instantiateViewController(identifier: HistoryListViewController.identifier) as? HistoryListViewController else { return HistoryListViewController() }
        
        sut.presenter = presenter
        sut.loadViewIfNeeded()
        return sut
    }
    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func test_historyListVC_viewDidLoad() {
        let sut = makeSUT()
        
        sut.viewDidLoad()
        XCTAssertTrue(presenter.onViewDidLoadCalled)
    }
    
    func test_historyListVC_floatingButtonTapped() {
        let sut = makeSUT()
        let currentStatus = sut.isFloatingButtonOpened
  
        sut.floatingActionButtonTapped(UIButton())

        XCTAssertTrue(presenter.onFloatingActionButtonTappedCalled)
        if currentStatus {
            XCTAssertTrue(presenter.onCloseFloatingActionsCalled)
        } else {
            XCTAssertTrue(presenter.onOpenFloatingActionsCalled)
        }
    }
    
    func test_historyListVC_closeFloatingActions() {
        let sut = makeSUT()
        sut.closeFloatingActions()
        
        XCTAssertTrue(presenter.onCloseFloatingActionsCalled)
        XCTAssertFalse(sut.isFloatingButtonOpened)
    }
    
    func test_historyListVC_openFloatingActions() {
        let sut = makeSUT()
        sut.openFloatingActions()
        
        XCTAssertTrue(presenter.onOpenFloatingActionsCalled)
        XCTAssertTrue(sut.isFloatingButtonOpened)
    }
    
    func test_historyListVC_rotateFloatingActionButton() {
        let sut = makeSUT()
        sut.rotateFloatingActionButton()
        
        XCTAssertTrue(presenter.onRotateFloatingActionButtonCalled)
    }
}
