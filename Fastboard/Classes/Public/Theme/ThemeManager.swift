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
            func updateAppearanceFor(view: UIView ) {
                // Manual update traitCollection
                if #available(iOS 13.0, *) {
                    let style = view.traitCollection.userInterfaceStyle
                    let isHide = view.isHidden
                    if !isHide {
                        view.isHidden = true
                    }
                    switch style {
                    case .light:
                        DispatchQueue.main.async {
                            view.overrideUserInterfaceStyle = .dark
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if !isHide {
                                    view.isHidden = false
                                }
                                view.overrideUserInterfaceStyle = .light
                            }
                        }
                    case .dark:
                        DispatchQueue.main.async {
                            view.overrideUserInterfaceStyle = .light
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if !isHide {
                                    view.isHidden = false
                                }
                                view.overrideUserInterfaceStyle = .dark
                            }
                        }
                    default: return
                    }
                } else {
                    (view as? FastThemeChangable)?.rebuildStyleForBeforeOS12()
                }
            }
            
            FastBoardSDK.weakTable.objectEnumerator().forEach { item in
                guard let view = item as? FastboardView else { return }
                updateAppearanceFor(view: view)
                let subPanelViews = view.totalPanels
                    .flatMap { $0.items }
                    .compactMap { $0 as? SubOpsItem }
                    .map { $0.subPanelView }
                for sub in subPanelViews {
                    updateAppearanceFor(view: sub)
                }
            }
        }
    }
    
    public func colorFor(_ type: ThemeComponentType) -> UIColor? {
        if #available(iOS 13.0, *) {
            return UIColor { [unowned self] collection in
                let color = self.theme(type, collection)
                return color
            }
        } else {
            return theme(type, nil)
        }
    }
}
