//
//  DefaultTheme.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit

public struct DefaultTheme {
    public static var defaultLightTheme: ThemeProvider {
        let map: [ThemeComponentType: UIColor] = [
            .background: .white,
            .border: .gray,
            .controlSelected: .black,
            .controlSelectedDark: .black,
            .controlNormal: .black,
            .controlDisable: .gray,
            .controlSelectedBg: UIColor(hexString: "#EAF2FF")
        ]
        return { type, collection in
            map[type]!
        }
    }
    
    public static var defaultDarkTheme: ThemeProvider {
        let map: [ThemeComponentType: UIColor] = [
            .background: .black,
            .border: .gray,
            .controlSelected: .systemBlue,
            .controlSelectedDark: .blue,
            .controlNormal: .black,
            .controlDisable: .gray,
            .controlSelectedBg: .systemGray
        ]
        return { type, collection in
            map[type]!
        }
    }
    
    @available (iOS 13, *)
    public static var defaultAutoTheme: ThemeProvider {
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
            @unknown default:
                return light(type, collection)
            }
        }
    }
}
