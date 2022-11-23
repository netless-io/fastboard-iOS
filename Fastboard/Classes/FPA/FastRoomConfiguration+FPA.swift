//
//  FastRoomConfiguration+FPA.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/12.
//

import Whiteboard

extension FastRoomConfiguration {
    ///   - useFPA: 是否使用FPA加速
    ///   其他参数见 FastConfiguration
    @objc
    @available (iOS 13.0, *)
    public convenience init(appIdentifier: String,
                            roomUUID: String,
                            roomToken: String,
                            region: Region,
                            userUID: String,
                            userPayload: FastUserPayload? = nil,
                            useFPA: Bool) {
        self.init(appIdentifier: appIdentifier,
                  roomUUID: roomUUID,
                  roomToken: roomToken,
                  region: region,
                  userUID: userUID,
                  userPayload: userPayload)
        whiteRoomConfig.nativeWebSocket = useFPA
        if useFPA {
            FpaProxyService.shared().setupDelegate(FPADelegate.shared)
        }
    }
}
