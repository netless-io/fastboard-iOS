//
//  UIView+Theme.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit

private var themeKey: Void?
extension UIView {
    var themeComponentType: ThemeComponentType? {
        get {
            objc_getAssociatedObject(self, &themeKey) as? ThemeComponentType
        }
        set {
            objc_setAssociatedObject(self, &themeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
