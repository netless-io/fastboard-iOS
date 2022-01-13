//
//  FastboardOverlay.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/11.
//

import Foundation
import Whiteboard

@objc
public enum OperationBarDirection: Int {
    case left = 0
    case right
}

@objc
public protocol FastboardOverlay: FastPanelControl, FastPanelDelegate {
    func setupWith(room: WhiteRoom, fastboardView: FastboardView, direction: OperationBarDirection)
    
    func invalidAllLayout()
    
    func updateControlBarLayout(direction: OperationBarDirection)
    
    func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?, shape: WhiteApplianceShapeTypeKey?)
    
    func updateStrokeColor(_ color: UIColor)
    
    func updateStrokeWidth(_ width: Float)
    
    func updateSceneState(_ scene: WhiteSceneState)
    
    func updateUndoEnable(_ enable: Bool)
    
    func updateRedoEnable(_ enable: Bool)
    
    func updateBoxState(_ state: WhiteWindowBoxState?)
}
