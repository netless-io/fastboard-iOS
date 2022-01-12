//
//  FastError.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation

enum ErrorType: Int {
    case setupSDK = 0
    case joinRoom = 1000
    case disconnected = 2000
}

let errorDomain = "io.agora.fastboard"

@objc
public class FastError: NSError {
    init(type: ErrorType, error: Error) {
        super.init(domain: errorDomain, code: type.rawValue, userInfo: (error as NSError).userInfo)
    }
    
    init(type: ErrorType, info: [String: Any]? = nil) {
        super.init(domain: errorDomain, code: type.rawValue, userInfo: info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
