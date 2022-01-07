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
