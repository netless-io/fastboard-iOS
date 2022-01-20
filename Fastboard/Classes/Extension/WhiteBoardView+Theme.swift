//
//  WhiteBoardView+Theme.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/6.
//

import UIKit
import Whiteboard

extension WhiteBoardView {
    @objc
    dynamic var themeBgColor: UIColor? {
        get { nil }
        set {
            backgroundColor = newValue
            traitCollectionUpdateHandler = { [weak self] _ in
                if #available(iOS 13.0, *) {
                    if let t = self?.traitCollection {
                        self?.backgroundColor = newValue?.resolvedColor(with: t)
                    }
                }
            }
        }
    }
}
