//
//  DefaultTheme.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit

public struct DefaultTheme {
    static var defaultLightTheme: ThemeProvider {
        let map: [ThemeComponentType: UIColor] = [
            .background: .systemBlue
        ]
        return { type, collection in
            map[type]!
        }
    }
    
    static var defaultDarkTheme: ThemeProvider {
        let map: [ThemeComponentType: UIColor] = [
            .background: .systemYellow
        ]
        return { type, collection in
            map[type]!
        }
    }
    
    @available (iOS 13, *)
    static var defaultAutoTheme: ThemeProvider {
        let light = defaultLightTheme
        let dark = defaultDarkTheme
        return { type, collection in
            guard let style = collection?.userInterfaceStyle else {
                return light(type, nil)
            }
            switch style {
            case .light, .unspecified:
                return light(type, collection)
            case .dark:
                return dark(type, collection)
            }
        }
    }
}
