//
//  StorageItem.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Whiteboard

extension WhiteRegionKey: Codable {}

struct StorageItem: Codable {
    enum FileType: CaseIterable {
        case img
        case pdf
        case video
        case music
        case ppt
        case word
        case unknown
        
        var availableSuffix: [String] {
            switch self {
            case .img:
                return ["jpg", "jpeg", "png", "webp"]
            case .pdf:
                return ["pdf"]
            case .video:
                return ["mp4"]
            case .music:
                return ["mp3", "aac"]
            case .ppt:
                return ["ppt", "pptx"]
            case .word:
                return ["doc", "docx"]
            case .unknown:
                return []
            }
        }
        
        init(fileName: String) {
            self = Self.allCases.first(where: { type in
                for eachSuffix in type.availableSuffix {
                    if fileName.hasSuffix(eachSuffix) {
                        return true
                    }
                }
                return false
            }) ?? .unknown
        }
    }
    
    var fileName: String
    var fileType: FileType { .init(fileName: fileName) }
    
    var taskType: WhiteConvertTypeV5 {
        if fileName.hasSuffix("pptx") { return .dynamic }
        return .static
    }
    
    let fileURL: URL
    let region: WhiteRegionKey
    let taskUUID: String
    let taskToken: String
}


let storageJsonPath = Bundle.main.path(forResource: "storage", ofType: "json")!
let storage = try! JSONDecoder().decode([StorageItem].self, from: Data(contentsOf: .init(fileURLWithPath: storageJsonPath)))
