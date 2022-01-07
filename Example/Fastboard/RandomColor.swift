//
//  RandomColor.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/1/7.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

func randomColor() -> UIColor {
    let indicates: [UIColor] = [
        .systemRed,
        .black,
        .systemOrange,
        .systemBlue,
        .systemGreen,
        .systemPink,
        .systemYellow,
        .systemGray,
        .systemPurple,
        .systemTeal
    ]
    let i = Int.random(in: 0..<10)
    return indicates[i]
}
