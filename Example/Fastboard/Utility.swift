//
//  Utility.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/1/7.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

func button(title: String, index: Int) -> UIButton {
    let btn = UIButton(type: .custom)
    btn.backgroundColor = randomColor()
    btn.setTitle(title, for: .normal)
    btn.tag = index
    let t = UIApplication.shared.windows.first?.traitCollection
    let hasCompact = t?.verticalSizeClass == .compact || t?.horizontalSizeClass == .compact
    if hasCompact {
        btn.contentEdgeInsets = .init(top: 4, left: 10, bottom: 4, right: 10)
    } else {
        btn.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    }
    return btn
}

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
