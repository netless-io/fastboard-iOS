//
//  FastboardManager.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit
import Whiteboard

public class FastboardManager: NSObject {
    /// Weak obtain all all the fastboard view create by self
    static var weakTable: NSHashTable<FastboardView> = .init(options: .weakMemory)
    
    /// Change this to update the whiteRoom ratio and whiteboardView ratio
    @objc
    public static var globalFastboardRatio: CGFloat = 16.0 / 9.0
    
    @objc
    public class func createFastboardWithConfiguration(_ configuration: FastConfiguration) -> Fastboard {
        func defaultOverlay() -> FastboardOverlay {
            if UIScreen.main.traitCollection.hasCompact {
                return CompactFastboardOverlay()
            } else {
                return RegularFastboardOverlay()
            }
        }
        let fastboardOverlay = configuration.customOverlay ?? defaultOverlay()
        let fastboardView = FastboardView(overlay: fastboardOverlay)
        let fastboard = Fastboard(view: fastboardView, roomConfig: configuration.whiteRoomConfig)
        let whiteSDK = WhiteSDK(whiteBoardView: fastboardView.whiteboardView, config: configuration.whiteSdkConfiguration, commonCallbackDelegate: fastboard.sdkDelegateProxy)
        fastboard.whiteSDK = whiteSDK
        
        weakTable.add(fastboardView)
        // Make sure the method be executed once.
        MethodHook.shared.start()
        // Guarantee the default theme will be applied
        ThemeManager.shared.start()
        return fastboard
    }
}
