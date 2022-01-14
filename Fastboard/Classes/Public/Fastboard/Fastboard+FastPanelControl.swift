//
//  Fastboard+FastPanelControl.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/7.
//

import Foundation

extension Fastboard: FastPanelControl {
    @objc
    public func dismissAllSubPanels() {
        view.dismissAllSubPanels()
    }
    
    @objc
    public func setAllPanel(hide: Bool) {
        view.setAllPanel(hide: hide)
    }
    
    @objc
    public func setPanelItemHide(item: DefaultOperationIdentifier, hide: Bool) {
        view.setPanelItemHide(item: item, hide: hide)
    }
}


