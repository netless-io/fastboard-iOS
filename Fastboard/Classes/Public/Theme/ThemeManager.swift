//
//  ThemeManager.swift
//  dsBridge
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit

@objc (FastboardThemeManager)
public class ThemeManager: NSObject {
    @objc public static let shared = ThemeManager()
    private override init() {
        if #available(iOS 13.0, *) {
            theme = DefaultTheme.defaultAutoTheme
        } else {
            theme = DefaultTheme.defaultLightTheme
        }
        super.init()
    }
    
    public var theme: ThemeProvider {
        didSet {
            FastBoardSDK.weakTable.objectEnumerator().forEach { item in
                guard let view = item as? FastboardView else { return }
                // Manual update traitCollection
                if #available(iOS 13.0, *) {
                    let style = view.traitCollection.userInterfaceStyle
                    view.isHidden = true
                    switch style {
                    case .light:
                        DispatchQueue.main.async {
                            view.overrideUserInterfaceStyle = .dark
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            view.isHidden = false
                            view.overrideUserInterfaceStyle = .light
                        }
                    case .dark:
                        DispatchQueue.main.async {
                            view.overrideUserInterfaceStyle = .light
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { view.isHidden = false
                            view.overrideUserInterfaceStyle = .dark
                        }
                    default: return
                    }
                } else {
                    view.rebuildStyleForBeforeOS12()
                }
            }
        }
    }
    
    public func colorFor(_ type: ThemeComponentType) -> UIColor? {
        if #available(iOS 13.0, *) {
            return UIColor { [weak self] collection in
                guard let self = self else { return .white }
                let color = self.theme(type, collection)
                return color
            }
        } else {
            return theme(type, nil)
        }
    }
}
