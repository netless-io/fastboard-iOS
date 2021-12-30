//
//  FastboardDelegate.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import Foundation

public protocol FastboardDelegate: AnyObject {
    func fastboard(_ fastboard: Fastboard, error: FastError)
    
    func fastboardUserKickedOut(_ fastboard: Fastboard, reason: String)
}
