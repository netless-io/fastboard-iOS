//
//  FPADelegate.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/2/16.
//

import Whiteboard

class FPADelegate: NSObject, FpaProxyServiceDelegate {
    static let shared = FPADelegate()
    private override init() {}
    
    public func onAccelerationSuccess(_ connectionInfo: FpaProxyServiceConnectionInfo) {
        print("FPADelegate: ", #function, connectionInfo)
    }
    
    public func onConnected(_ connectionInfo: FpaProxyServiceConnectionInfo) {
        print("FPADelegate: ", #function, connectionInfo)
    }
    
    public func onDisconnectedAndFallback(_ connectionInfo: FpaProxyServiceConnectionInfo, reason: FpaFailedReason) {
        print("FPADelegate: ", #function, connectionInfo, reason)
    }
    
    public func onConnectionFailed(_ connectionInfo: FpaProxyServiceConnectionInfo, reason: FpaFailedReason) {
        print("FPADelegate: ", #function, connectionInfo, reason)
    }
}
