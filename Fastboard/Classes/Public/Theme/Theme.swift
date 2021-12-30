//
//  Theme.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit

public enum ThemeComponentType {
    case brand
    case background
    case controlSelected
    case controlSelectedDark
    case controlSelectedBg
    case controlNormal
    case controlDisable
    case border
}

public typealias ThemeProvider = ((ThemeComponentType, UITraitCollection?)-> UIColor)
