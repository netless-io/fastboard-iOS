//
//  ThemeManager.swift
//  dsBridge
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit
import Whiteboard

extension UIView {
    @objc dynamic var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension WhiteBoardView {
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Workaround for dynamic color support
        if #available(iOS 13.0, *) {
            backgroundColor = backgroundColor
        } else {
        }
    }
}

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


@objc (FastboardThemeManager)
public class ThemeManager: NSObject {
    @objc public static let shared = ThemeManager()
    private override init() {
        super.init()
        if #available(iOS 13.0, *) {
            apply(DefaultTheme.defaultAutoTheme)
        } else {
            apply(DefaultTheme.defaultLightTheme)
        }
    }
    
    public func apply(_ theme: ThemeAble) {
        updateFastboard(theme.whiteboardAssets)
        updateControlBar(theme.controlBarAssets)
        updatePanelItem(theme.panelItemAssets)
        
        AppearanceManager.shared.commitUpdate()
    }
    
    func updatePanelItem(_ asset: PanelItemAssets) {
        PanelItemButton.appearance().iconNormalColor = asset.normalIconColor
        PanelItemButton.appearance().iconSelectedColor = asset.selectedIconColor
        PanelItemButton.appearance().iconHighlightBgColor = asset.highlightBgColor
        
        UIImageView.appearance(whenContainedInInstancesOf: [PanelItemButton.self]).tintColor = asset.subOpsIndicatorColor
        UILabel.appearance(whenContainedInInstancesOf: [ControlBar.self]).textColor = asset.pageTextLabelColor
    }
    
    func updateFastboard(_ asset: WhiteboardAssets) {
        WhiteBoardView.appearance().backgroundColor = asset.whiteboardBackgroundColor
        FastboardView.appearance().backgroundColor = asset.containerColor
        FastBoardSDK.weakTable.allObjects.forEach { view in
            view.whiteboardView.backgroundColor = asset.whiteboardBackgroundColor
        }
    }
    
    func updateControlBar(_ asset: ControlBarAssets) {
        ControlBar.appearance().backgroundColor = asset.backgroundColor
        ControlBar.appearance().borderColor = asset.borderColor
        UIVisualEffectView.appearance(whenContainedInInstancesOf: [ControlBar.self]).effect = asset.effectStyle
        
        SubPanelContainer.appearance().backgroundColor = asset.backgroundColor
        SubPanelContainer.appearance().borderColor = asset.borderColor
        UIVisualEffectView.appearance(whenContainedInInstancesOf: [SubPanelContainer.self]).effect = asset.effectStyle
    }
}
