//
//  FastPanelControl.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/7.
//

import Foundation

protocol FastPanelControl {
    func setAllPanel(hide: Bool)
    
    func setPanelItemHide(item: DefaultOperationIdentifier, hide: Bool)
}
