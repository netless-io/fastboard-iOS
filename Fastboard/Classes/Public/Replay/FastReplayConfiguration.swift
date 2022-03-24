//
//  FastReplayConfiguration.swift
//  fastboard
//
//  Created by xuyunshi on 2022/3/24.
//

import Foundation
import Whiteboard

@objc
public class FastReplyConfiguration: NSObject {
    var appIdentifier: String
    var playerConfig: WhitePlayerConfig
    var mediaUrl: String
    
    @objc
    public init(appIdentifier: String,
                roomUUID: String,
                roomToken: String,
                beginTime: TimeInterval,
                duration: TimeInterval,
                mediaUrl: String) {
        self.mediaUrl = mediaUrl
        self.appIdentifier = appIdentifier
        playerConfig = .init(room: roomUUID, roomToken: roomToken)
        playerConfig.beginTimestamp = .init(value: beginTime)
        playerConfig.duration = .init(value: duration)
    }
}
