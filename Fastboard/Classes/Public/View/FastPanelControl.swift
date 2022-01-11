//
//  FastPanelControl.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/7.
//

import Foundation

@objc
public protocol FastPanelControl: AnyObject {
    func setAllPanel(hide: Bool)
    
    func setPanelItemHide(item: DefaultOperationIdentifier, hide: Bool)
}
