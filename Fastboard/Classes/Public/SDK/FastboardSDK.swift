//
//  FastboardSDK.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit
import Whiteboard

func methodExchange(cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    let original = class_getInstanceMethod(cls, originalSelector)!
    let target = class_getInstanceMethod(cls, swizzledSelector)!
    method_exchangeImplementations(original, target)
}

private struct Initializer {
    private init() {
        methodExchange(cls: UIViewController.self,
                       originalSelector: #selector(UIViewController.traitCollectionDidChange(_:)),
                       swizzledSelector: #selector(UIViewController.exchangedTraitCollectionDidChange(_:)))
        
        methodExchange(cls: UIView.self,
                       originalSelector: #selector(UIView.traitCollectionDidChange(_:)),
                       swizzledSelector: #selector(UIView.exchangedTraitCollectionDidChange(_:)))
    }
    static let shared = Initializer()
}

@objc public class FastBoardSDK: NSObject {
    static var weakTable: NSHashTable<FastboardView> = .init(options: .weakMemory)
    
    @objc public static var globalFastboardRatio: CGFloat = 16.0 / 9.0
    
    @objc public class func createFastboardWith(appId: String,
                                                roomUUID: String,
                                                roomToken: String,
                                                userUID: String)  -> Fastboard {
        let whiteConfig = WhiteSdkConfiguration(app: appId)
        whiteConfig.renderEngine = .canvas
        whiteConfig.userCursor = false
        whiteConfig.useMultiViews = true
        
        let roomConfig = WhiteRoomConfig(uuid: roomUUID, roomToken: roomToken, uid: userUID)
        roomConfig.disableNewPencil = false
        
        let windowParas = WhiteWindowParams()
        windowParas.chessboard = false
        windowParas.containerSizeRatio = NSNumber(value: 1 / globalFastboardRatio)
        roomConfig.windowParams = windowParas
        
        return createFastboardWith(whiteSDKConfig: whiteConfig, whiteRoomConfig: roomConfig)
    }
    
    @objc public class func createFastboardWith(whiteSDKConfig: WhiteSdkConfiguration,
                                                whiteRoomConfig: WhiteRoomConfig) -> Fastboard {
        let view: FastboardView
        if UIScreen.main.traitCollection.hasCompact {
            view = CompactFastboardView()
        } else {
            view = RegularFastboardView()
        }
        let fastboard = Fastboard(view: view, roomConfig: whiteRoomConfig)
        let sdk = WhiteSDK(whiteBoardView: view.whiteboardView,
                           config: whiteSDKConfig,
                           commonCallbackDelegate: fastboard.sdkDelegateProxy)
        fastboard.whiteSDK = sdk
        weakTable.add(view)
        
        // Make sure the method be executed once.
        _ = Initializer.shared
        // Guarantee the default theme will be applied
        _ = ThemeManager.shared
        return fastboard
    }
}
