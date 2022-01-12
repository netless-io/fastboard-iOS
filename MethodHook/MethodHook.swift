//
//  MethodHook.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/12.
//

import Foundation

func methodExchange(cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    let original = class_getInstanceMethod(cls, originalSelector)!
    let target = class_getInstanceMethod(cls, swizzledSelector)!
    method_exchangeImplementations(original, target)
}

struct MethodHook {
    private init() {
        methodExchange(cls: UIViewController.self,
                       originalSelector: #selector(UIViewController.traitCollectionDidChange(_:)),
                       swizzledSelector: #selector(UIViewController.exchangedTraitCollectionDidChange(_:)))
        
        methodExchange(cls: UIView.self,
                       originalSelector: #selector(UIView.traitCollectionDidChange(_:)),
                       swizzledSelector: #selector(UIView.exchangedTraitCollectionDidChange(_:)))
    }
    static let shared = MethodHook()
    
    /// Empty function for more readable
    func start() {}
}
