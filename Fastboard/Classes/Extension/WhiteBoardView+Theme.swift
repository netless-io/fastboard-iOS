//
//  WhiteBoardView+Theme.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/6.
//

import UIKit
import Whiteboard

extension WhiteBoardView {
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Workaround for dynamic color support
        if #available(iOS 13.0, *) {
            backgroundColor = backgroundColor
        } else {
        }
    }
    
    @objc
    dynamic var themeBgColor: UIColor? {
        get { nil }
        set {
            backgroundColor = newValue
        }
    }
}
