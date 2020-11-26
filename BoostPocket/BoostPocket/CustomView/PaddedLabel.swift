//
//  PaddedLabel.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/26.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
    // MARK: - Properties
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.width
        let heigth = superContentSize.height + padding.height
        return CGSize(width: width, height: heigth)
    }
    
    private var padding: CGSize = .init(width: 0, height: 0)
    
    // MARK: Padding
    @IBInspectable var paddingWidth: CGFloat {
        get { padding.width }
        set { padding.width = newValue }
    }
    @IBInspectable var paddingHeight: CGFloat {
        get { padding.height }
        set { padding.height = newValue }
    }

}
