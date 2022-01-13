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
        let wsc = WhiteSdkConfiguration(app: appIdentifier)
        wsc.renderEngine = .canvas
        wsc.userCursor = false
        wsc.useMultiViews = true
        wsc.region = region.toWhiteRegion()
        if #available(iOS 14.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                wsc.deviceType = .desktop
            }
        }
        whiteSdkConfiguration = wsc
        let wrc = WhiteRoomConfig(uuid: roomUUID, roomToken: roomToken, uid: userUID)
        wrc.disableNewPencil = false
        let windowParas = WhiteWindowParams()
        windowParas.chessboard = false
        windowParas.containerSizeRatio = NSNumber(value: 1 / FastboardManager.globalFastboardRatio)
        wrc.windowParams = windowParas
        whiteRoomConfig = wrc
        super.init()
    }
    
    @available(*, deprecated, message: "use the designed init instead")
    public override init() {
        #if DEBUG
        fatalError("use the designed init instead")
        #else
        self.whiteRoomConfig = WhiteRoomConfig()
        self.whiteSdkConfiguration = WhiteSdkConfiguration.init(app: "")
        super.init()
        #endif
    }
}
