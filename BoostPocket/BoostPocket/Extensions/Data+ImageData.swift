//
//  Data+ImageData.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/26.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    func getCoverImage() -> Data? {
        let randomNumber = Int.random(in: 1...7)
        return UIImage(named: "cover\(randomNumber)")?.pngData()
    }
}
