//
//  FastRoomThemeManager.swift
//  dsBridge
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit
import Whiteboard

let prefersSchemeUpdateNotificationName = Notification.Name("prefersSchemeUpdateNotificationName")
let teleboxThemeUpdateNotificationName = Notification.Name("teleboxThemeUpdateNotificationName")

/// Manage the fastboard theme style
@objc
public class FastRoomThemeManager: NSObject {
    @objc
    public static let shared = FastRoomThemeManager()
    
    private(set) var currentThemeAsset: FastRoomThemeAsset
    
    override private init() {
        if #available(iOS 13.0, *) {
            self.currentThemeAsset = FastRoomDefaultTheme.defaultAutoTheme
        } else {
            self.currentThemeAsset = FastRoomDefaultTheme.defaultLightTheme
        }
        super.init()
        apply(currentThemeAsset)
    }
    
    /// You should call it before fastboard create
    @objc
    public func updateIcons(using bundle: Bundle) {
        iconsBundle = bundle
    }
    
    @objc
    public func apply(_ theme: FastRoomThemeAsset) {
        currentThemeAsset = theme
        updateControlBar(theme.controlBarAssets)
        updatePanelItem(theme.panelItemAssets)
        
        NotificationCenter.default.post(name: prefersSchemeUpdateNotificationName, object: nil, userInfo: ["scheme": theme.prefersColorScheme as Any])
        NotificationCenter.default.post(name: teleboxThemeUpdateNotificationName, object: nil, userInfo: ["theme": theme.teleboxTheme as Any])
        
        AppearanceManager.shared.commitUpdate()
    }
    
    @objc
    func updatePanelItem(_ asset: FastRoomPanelItemAssets) {
        FastRoomPanelItemButton.appearance().iconNormalColor = asset.normalIconColor
        FastRoomPanelItemButton.appearance().iconSelectedColor = asset.selectedIconColor
        FastRoomPanelItemButton.appearance().iconHighlightBgColor = asset.highlightBgColor
        FastRoomPanelItemButton.appearance().justExecutionNormalColor = asset.normalIconColor
        FastRoomPanelItemButton.appearance().highlightColor = asset.highlightColor
        FastRoomPanelItemButton.appearance().iconSelectedBgColor = asset.selectedIconBgColor
        FastRoomPanelItemButton.appearance().selectedBackgroundCornerradius = asset.selectedBackgroundCornerRadius
        FastRoomPanelItemButton.appearance().selectedBackgroundEdgeInset = asset.selectedBackgroundEdgeinset
        
        UIImageView.appearance(whenContainedInInstancesOf: [FastRoomPanelItemButton.self]).tintColor = asset.subOpsIndicatorColor
        PageIndicatorLabel.appearance().configurableTextColor = asset.pageTextLabelColor
    }
    
    @objc
    func updateControlBar(_ asset: FastRoomControlBarAssets) {
        FastRoomControlBar.appearance().backgroundColor = asset.backgroundColor
        FastRoomControlBar.appearance().borderColor = asset.borderColor
        UIVisualEffectView.appearance(whenContainedInInstancesOf: [FastRoomControlBar.self]).effect = asset.effectStyle
        
        SubPanelContainer.appearance().backgroundColor = asset.backgroundColor
        SubPanelContainer.appearance().borderColor = asset.borderColor
        UIVisualEffectView.appearance(whenContainedInInstancesOf: [SubPanelContainer.self]).effect = asset.effectStyle
    }
}
