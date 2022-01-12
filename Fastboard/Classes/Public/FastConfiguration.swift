//
//  FastConfiguration.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/12.
//

import Foundation
import Whiteboard

public class FastConfiguration: NSObject {
    /// Update whiteSDK configuration here
    @objc
    public let whiteSdkConfiguration: WhiteSdkConfiguration
    
    /// Update whiteRoom configuration here
    @objc
    public let whiteRoomConfig: WhiteRoomConfig
    
    /// Assign a custom overlay to create your own overlay style
    @objc
    public var customOverlay: FastboardOverlay? = nil
 
    /// Create FastConfiguration
    /// - Parameters:
    ///   - appIdentifier: appIdentifier 白板项目的唯一标识。详见[获取白板项目的 App Identifier](https://docs.agora.io/cn/whiteboard/enable_whiteboard?platform=iOS#获取-app-identifier)。
    ///   - roomUUID: uuid 房间 UUID，即房间唯一标识符。
    ///   - roomToken: roomToken 用于鉴权的 Room Token。生成该 Room Token 的房间 UUID 必须和上面传入的房间 UUID 一致。
    ///   - region: 数据中心
    ///   - userUID: 用户标识，可以为任意 string。
    @objc
    public init(appIdentifier: String,
                roomUUID: String,
                roomToken: String,
                region: Region,
                userUID: String) {
        let whiteSdkConfiguration = WhiteSdkConfiguration(app: appIdentifier)
        whiteSdkConfiguration.renderEngine = .canvas
        whiteSdkConfiguration.userCursor = false
        whiteSdkConfiguration.useMultiViews = true
        whiteSdkConfiguration.region = region.toWhiteRegion()
        self.whiteSdkConfiguration = whiteSdkConfiguration
        let whiteRoomConfig = WhiteRoomConfig(uuid: roomUUID, roomToken: roomToken, uid: userUID)
        whiteRoomConfig.disableNewPencil = false
        let windowParas = WhiteWindowParams()
        windowParas.chessboard = false
        windowParas.containerSizeRatio = NSNumber(value: 1 / FastboardManager.globalFastboardRatio)
        whiteRoomConfig.windowParams = windowParas
        self.whiteRoomConfig = whiteRoomConfig
    }
    
    @available(*, deprecated, message: "use the designed init instead")
    public override init() {
        #if DEBUG
        fatalError("use the designed init instead")
        #else
        super.init()
        #endif
    }
}
