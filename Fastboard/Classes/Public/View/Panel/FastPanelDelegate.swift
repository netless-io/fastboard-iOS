//
//  FastPanelDelegate.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/31.
//

import Foundation

/// Represents a fastpanel behavior
@objc
public protocol FastPanelDelegate: AnyObject {
    func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem)
}
