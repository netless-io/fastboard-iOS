//
//  FastConfiguration+FPA.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/12.
//

import Whiteboard

extension FastConfiguration {
    ///   - useFPA: 是否使用FPA加速
    ///   其他参数见 FastConfiguration
    @objc
    @available (iOS 13.0, *)
    public convenience init(appIdentifier: String,
                            roomUUID: String,
                            roomToken: String,
                            region: Region,
                            userUID: String,
                            useFPA: Bool) {
        self.init(appIdentifier: appIdentifier,
                  roomUUID: roomUUID,
                  roomToken: roomToken,
                  region: region,
                  userUID: userUID)
        whiteRoomConfig.nativeWebSocket = useFPA
        if useFPA {
            WhiteFPA.setupFpa(WhiteFPA.defaultFpaConfig(), chain: WhiteFPA.defaultChain())
            FpaProxyService.shared().setupDelegate(FPADelegate.shared)
        }
    }
}
