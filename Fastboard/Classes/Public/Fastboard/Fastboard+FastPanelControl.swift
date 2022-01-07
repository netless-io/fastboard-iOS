//
//  Fastboard+FastPanelControl.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/7.
//

import Foundation

extension Fastboard: FastPanelControl {
    public func setAllPanel(hide: Bool) {
        view.setAllPanel(hide: hide)
    }
    
    public func setPanelItemHide(item: DefaultOperationKey, hide: Bool) {
        view.setPanelItemHide(item: item, hide: hide)
    }
}
