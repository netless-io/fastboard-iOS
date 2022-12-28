//
//  CustomColor.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/2/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

@objc
public class CustomColor:NSObject, Codable {
    @objc
    public let controlBarBg: String
    
    @objc
    public let selColor: String
    
    @objc
    public let highlightColor: String
    
    @objc
    public let iconSelectedBgColor: String
    
    @objc
    public let selectedColorItemBgColor: String
}

let json = Bundle.main.path(forResource: "customColor", ofType: "json")!
let customColor = try! JSONDecoder().decode(CustomColor.self, from: try! Data(contentsOf: URL(fileURLWithPath: json)))

/// For OC
@objc
public class OCBridge: NSObject {
    @objc
    public class func getCustomColor() -> CustomColor { customColor }
}
