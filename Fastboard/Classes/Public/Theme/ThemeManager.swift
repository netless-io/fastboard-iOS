//
//  ThemeManager.swift
//  dsBridge
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit
import Whiteboard

@objc (FastboardThemeManager)
public class ThemeManager: NSObject {
    @objc
    public static let shared = ThemeManager()
    
    private override init() {
        super.init()
        if #available(iOS 13.0, *) {
            apply(DefaultTheme.defaultAutoTheme)
        } else {
            apply(DefaultTheme.defaultLightTheme)
        }
    }
    
    /// You should call it before fastboard create
    @objc
    public func updateIcons(using bundle: Bundle) {
        iconsBundle = bundle
    }
    
    @objc
    public func apply(_ theme: ThemeAsset) {
        updateFastboard(theme.whiteboardAssets)
        updateControlBar(theme.controlBarAssets)
        updatePanelItem(theme.panelItemAssets)
        
        AppearanceManager.shared.commitUpdate()
    }
    
    @objc
    func updatePanelItem(_ asset: PanelItemAssets) {
        PanelItemButton.appearance().iconNormalColor = asset.normalIconColor
        PanelItemButton.appearance().iconSelectedColor = asset.selectedIconColor
        PanelItemButton.appearance().iconHighlightBgColor = asset.highlightBgColor
        PanelItemButton.appearance().justExecutionNormalColor = asset.normalIconColor
        PanelItemButton.appearance().highlightColor = asset.highlightColor
        PanelItemButton.appearance().iconSelectedBgColor = asset.selectedIconBgColor
        
        UIImageView.appearance(whenContainedInInstancesOf: [PanelItemButton.self]).tintColor = asset.subOpsIndicatorColor
        PageIndicatorLabel.appearance().configurableTextColor = asset.pageTextLabelColor
    }
    
    @objc
    func updateFastboard(_ asset: WhiteboardAssets) {
        WhiteBoardView.appearance().backgroundColor = asset.whiteboardBackgroundColor
        FastboardView.appearance().backgroundColor = asset.containerColor
        WhiteBoardView.appearance().themeBgColor = asset.whiteboardBackgroundColor
    }
    
    @objc
    func updateControlBar(_ asset: ControlBarAssets) {
        ControlBar.appearance().backgroundColor = asset.backgroundColor
        ControlBar.appearance().borderColor = asset.borderColor
        UIVisualEffectView.appearance(whenContainedInInstancesOf: [ControlBar.self]).effect = asset.effectStyle
        
        SubPanelContainer.appearance().backgroundColor = asset.backgroundColor
        SubPanelContainer.appearance().borderColor = asset.borderColor
        UIVisualEffectView.appearance(whenContainedInInstancesOf: [SubPanelContainer.self]).effect = asset.effectStyle
    }
}
