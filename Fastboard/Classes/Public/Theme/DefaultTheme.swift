//
//  DefaultTheme.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit

public class DefaultTheme: NSObject {
    
    @objc
    public class var defaultLightTheme: ThemeAsset {
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
    
    @objc
    public static var defaultDarkTheme: ThemeAsset {
        ThemeAsset(whiteboardAssets: WhiteboardAssets(whiteboardBackgroundColor: .black,
                                                      containerColor: .lightGray),
                   controlBarAssets: ControlBarAssets(backgroundColor: .black,
                                                      borderColor: .lightGray),
                   panelItemAssets: .init(normalIconColor: .gray,
                                          selectedIconColor: .white,
                                          highlightBgColor: .darkGray,
                                          subOpsIndicatorColor: .white,
                                          pageTextLabelColor: .gray))
    }
    
    @available(iOS 13, *)
    @objc
    public static var defaultAutoTheme: ThemeAsset {
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
