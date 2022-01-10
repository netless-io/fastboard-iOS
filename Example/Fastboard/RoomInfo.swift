//
//  RoomInfo.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/1/10.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

enum RoomInfo: String {
    case APPID
    case ROOMTOKEN
    case ROOMUUID
    
    fileprivate func value<T>(for key: String) -> T {
        guard let value = Bundle.main.infoDictionary?[key] as? T else {
            fatalError("Invalid or missing Info.plist key: \(key)")
        }
        return value
    }
    
    var value: String {
        value(for: rawValue) as String
    }
}
