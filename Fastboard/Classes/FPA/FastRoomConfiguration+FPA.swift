//
//  FastRoomConfiguration+FPA.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/12.
//

import Whiteboard

extension FastRoomConfiguration {
    ///   - useFPA: Represents whether the acceleration option is enabled
    ///   Other options for reference [FastConfiguration](FastConfiguration)
    @objc
    @available (iOS 13.0, *)
    public convenience init(appIdentifier: String,
                            roomUUID: String,
                            roomToken: String,
                            region: Region,
                            userUID: String,
                            useFPA: Bool,
                            userPayload: FastUserPayload? = nil,
                            audioMixerDelegate: FastAudioMixerDelegate? = nil
    ) {
        self.init(appIdentifier: appIdentifier,
                  roomUUID: roomUUID,
                  roomToken: roomToken,
                  region: region,
                  userUID: userUID,
                  userPayload: userPayload,
                  audioMixerDelegate: audioMixerDelegate)
        whiteRoomConfig.nativeWebSocket = useFPA
        if useFPA {
            FpaProxyService.shared().setupDelegate(FPADelegate.shared)
        }
    }
}
