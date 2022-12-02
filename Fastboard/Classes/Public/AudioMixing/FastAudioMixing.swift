//
//  FastAudioMixing.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/12/2.
//

import Foundation
import Whiteboard

@objc
public protocol FastAudioMixerDelegate {
    func startAudioMixing(audioBridge: WhiteAudioMixerBridge, filePath: String, loopback: Bool, replace: Bool, cycle: Int)
    func stopAudioMixing(audioBridge: WhiteAudioMixerBridge)
    func pauseAudioMixing(audioBridge: WhiteAudioMixerBridge)
    func resumeAudioMixing(audioBridge: WhiteAudioMixerBridge)
    func setAudioMixingPosition(audioBridge: WhiteAudioMixerBridge, _ position: Int)
}
