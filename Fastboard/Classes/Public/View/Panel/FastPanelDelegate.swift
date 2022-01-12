//
//  FastPanelDelegate.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/31.
//

import Foundation

@objc
public protocol FastPanelDelegate: AnyObject {
    func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem)
}
