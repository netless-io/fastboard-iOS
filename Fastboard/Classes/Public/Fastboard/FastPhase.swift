//
//  FastPhase.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/7.
//

import Foundation

public enum FastPhase: Int {
    case connecting = 0
    case connected
    case reconnecting
    case disconnecting
    case disconnected
    case unknown
}
