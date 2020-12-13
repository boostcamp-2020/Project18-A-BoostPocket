//
//  HistoryListSupport.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/13.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol HistoryListVCPresenter: AnyObject {
    var onViewDidLoadCalled: Bool { get }
    var onFloatingActionButtonTappedCalled: Bool { get }
    var onCloseFloatingActionsCalled: Bool { get }
    var onOpenFloatingActionsCalled: Bool { get }
    var onRotateFloatingActionButtonCalled: Bool { get }
    
    func onViewDidLoad()
    func onFloatingActionButtonTapped()
    func onCloseFloatingActions()
    func onOpenFloatingActions()
    func onRotateFloatingActionButton()
}
