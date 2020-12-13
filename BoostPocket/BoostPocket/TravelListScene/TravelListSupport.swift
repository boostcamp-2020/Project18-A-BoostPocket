//
//  TravelListSupport.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/12/13.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

enum Layout {
    case defaultLayout
    case squareLayout
    case rectangleLayout
}

protocol TravelListVCPresenter: AnyObject {
    var onViewDidLoadCalled: Bool { get }
    var onLayoutButtonTappedCalled: Bool { get }
    var onDefaultLayoutButtonTappedCalled: Bool { get }
    var onSquareLayoutButtonTappedCalled: Bool { get }
    var onRectangleLayoutButtonTappedCalled: Bool { get }
    
    func onViewDidLoad()
    func onLayoutButtonTapped()
    func onDefaultLayoutButtonTapped()
    func onSquareLayoutButtonTapped()
    func onRectangleLayoutButtonTapped()
}
