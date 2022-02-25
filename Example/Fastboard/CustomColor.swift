//
//  CustomColor.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/2/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

struct CustomColor: Codable {
    let controlBarBg: String
    let selColor: String
    let highlightColor: String
    let iconSelectedBgColor: String
}

let json = Bundle.main.path(forResource: "customColor", ofType: "json")!
let customColor = try! JSONDecoder().decode(CustomColor.self, from: try! Data(contentsOf: URL(fileURLWithPath: json)))
