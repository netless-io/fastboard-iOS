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
    
    /// All the subPanels will be dismissed temporally
    /// It will show again after a touch on SubOpsItem
    func dismissAllSubPanels()
}
