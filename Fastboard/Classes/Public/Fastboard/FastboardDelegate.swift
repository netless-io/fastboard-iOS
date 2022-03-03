//
//  FastboardDelegate.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import Foundation
import Whiteboard

/// Represents the fastboard behavior
@objc
public protocol FastboardDelegate: AnyObject {
    func fastboard(_ fastboard: Fastboard, error: FastError)
    
    func fastboardUserKickedOut(_ fastboard: Fastboard, reason: String)
    
    func fastboardPhaseDidUpdate(_ fastboard: Fastboard, phase: FastRoomPhase)
    
    @objc optional
    func fastboardDidSetupOverlay(_ fastboard: Fastboard, overlay: FastboardOverlay?)
}
