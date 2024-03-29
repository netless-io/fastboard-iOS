//
//  DelegateProxy.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import Foundation
import Whiteboard
#if canImport(FastboardDynamic)
import FastboardDynamic
#endif

class WhiteRoomCallBackDelegateProxy: FastProxy, WhiteRoomCallbackDelegate {}

class WhiteCommonCallbackDelegateProxy: FastProxy, WhiteCommonCallbackDelegate{}
