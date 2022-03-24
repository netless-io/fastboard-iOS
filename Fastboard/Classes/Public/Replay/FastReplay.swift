//
//  FastReplay.swift
//  dsBridge
//
//  Created by xuyunshi on 2022/3/24.
//

import Foundation
import Whiteboard

@objc
public class FastReply: NSObject {
    var view: FastReplayView
    var whiteSDK: WhiteSDK!
    
    init(configuration: FastReplyConfiguration) {
        view = FastReplayView()
        let sdkConfig = WhiteSdkConfiguration(app: configuration.appIdentifier)
        super.init()
        whiteSDK = WhiteSDK(whiteBoardView: view, config: sdkConfig, commonCallbackDelegate: self)
        whiteSDK.createReplayer(with: configuration.playerConfig, callbacks: self) { success, player, error in
            
        }
//        WhiteCombinePlayer(mediaUrl: <#T##URL#>)
    }
    
//    lazy var combinePlayer = WhiteCombinePlayer(nativePlayer: <#T##AVPlayer#>, whitePlayer: <#T##WhitePlayer#>)
}

extension FastReply: WhiteCommonCallbackDelegate {
    
}

extension FastReply: WhitePlayerEventDelegate {
    
}
