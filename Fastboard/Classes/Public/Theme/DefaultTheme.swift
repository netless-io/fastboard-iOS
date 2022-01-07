//
//  DefaultTheme.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit

public struct DefaultTheme {
    public static var defaultLightTheme: ThemeAble {
        ThemeAsset(whiteboardAssets: WhiteboardAssets(whiteboardBackgroundColor: .white,
                                                      containerColor: .lightGray),
                   controlBarAssets: ControlBarAssets(backgroundColor: .white,
                                                      borderColor: .lightGray),
                   panelItemAssets: .init(normalIconColor: .black,
                                          selectedIconColor: .systemBlue,
                                          highlightBgColor: .init(hexString: "E8F0FE"),
                                          subOpsIndicatorColor: .black,
                                          pageTextLabelColor: .black))
    }
    
    public static var defaultDarkTheme: ThemeAble {
        ThemeAsset(whiteboardAssets: WhiteboardAssets(whiteboardBackgroundColor: .black,
                                                      containerColor: .lightGray),
                   controlBarAssets: ControlBarAssets(backgroundColor: .black,
                                                      borderColor: .lightGray),
                   panelItemAssets: .init(normalIconColor: .white,
                                          selectedIconColor: .systemBlue,
                                          highlightBgColor: .lightGray,
                                          subOpsIndicatorColor: .lightGray,
                                          pageTextLabelColor: .white))
    }
    
    @available(iOS 13, *)
    public static var defaultAutoTheme: ThemeAble {
        let fastAsset = WhiteboardAssets(whiteboardBackgroundColor: .systemBackground, containerColor: .secondarySystemBackground)
        let controlBarAssets = ControlBarAssets(backgroundColor: .clear, borderColor: .separator, effectStyle: .init(style: .systemMaterial))
        let panelItemAssets = PanelItemAssets(normalIconColor: .init(dynamicProvider: { c in
            if c.userInterfaceStyle == .dark {
                return defaultDarkTheme.panelItemAssets.normalIconColor
            } else {
                return defaultLightTheme.panelItemAssets.normalIconColor
            }
        }), selectedIconColor: .init(dynamicProvider: { c in
            if c.userInterfaceStyle == .dark {
                return defaultDarkTheme.panelItemAssets.selectedIconColor
            } else {
                return defaultLightTheme.panelItemAssets.selectedIconColor
            }
        }), highlightBgColor: .init(dynamicProvider: { c in
            if c.userInterfaceStyle == .dark {
                return defaultDarkTheme.panelItemAssets.highlightBgColor
            } else {
                return defaultLightTheme.panelItemAssets.highlightBgColor
            }
        }), subOpsIndicatorColor: .init(dynamicProvider: { c in
            if c.userInterfaceStyle == .dark {
                return defaultDarkTheme.panelItemAssets.subOpsIndicatorColor
            } else {
                return defaultLightTheme.panelItemAssets.subOpsIndicatorColor
            }
        }), pageTextLabelColor: UIColor.label)
        
        return ThemeAsset(whiteboardAssets: fastAsset,
                   controlBarAssets: controlBarAssets,
                          panelItemAssets: panelItemAssets
        )
    }
}
