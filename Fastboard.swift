//
//  Fastboard.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import UIKit
import Whiteboard

@objc public class Fastboard: NSObject {
    public let view: FastboardView
    public var whiteSDK: WhiteSDK!
    public var room: WhiteRoom? {
        didSet {
            initState()
        }
    }
    let multiDelegate: MultiWeakDelegate<WhiteRoomCallbackDelegate> = .init()
    
    public weak var delegate: FastboardDelegate?
    let roomConfig: WhiteRoomConfig

    // MARK: - Public
    public func joinRoom(completionHandler: @escaping ((FastError?)->Void)) {
        whiteSDK.joinRoom(with: roomConfig,
                          callbacks: self) { [weak self] success, room, error in
            if let error = error {
                let fError = FastError(type: .joinRoom, error: error)
                completionHandler(fError)
                return
            }
            guard let room = room else {
                let fError = FastError(type: .joinRoom, info: ["info": "join success without room"])
                completionHandler(fError)
                return
            }
            self?.room = room
            completionHandler(nil)
        }
    }
    
    func test() {
    }
    
    // MARK: - Private
    func initState() {
        room?.getStateWithResult({ state in
            // TODO
        })
    }
    
    init(view: FastboardView, roomConfig: WhiteRoomConfig){
        self.view = view
        self.roomConfig = roomConfig
    }
}

extension Fastboard: WhiteCommonCallbackDelegate {
    public func throwError(_ error: Error) {
        delegate?.fastboard?(self, warning: (error as NSError).userInfo)
    }
    
    public func sdkSetupFail(_ error: Error) {
        delegate?.fastboard?(self, error: FastError(type: .setupSDK, error: error))
    }
}

extension Fastboard: WhiteRoomCallbackDelegate {
    public func firePhaseChanged(_ phase: WhiteRoomPhase) {
        delegate?.fastboardPhaseChanged?(self, phase: phase)
    }
    
    public func fireRoomStateChanged(_ modifyState: WhiteRoomState!) {
        if let memberState = modifyState.memberState {
            if let stokeWidth = memberState.strokeWidth?.floatValue {
                delegate?.fastboardStrokeWidthUpdate?(self, strokeWidth: CGFloat(stokeWidth))
            }
            delegate?.fastboardStrokeColorUpdate?(self, color: UIColor(numberArray: memberState.strokeColor))
        }
        if let sceneState = modifyState.sceneState {
            delegate?.fastboardSceneUpdate?(self, sceneState: sceneState)
        }
    }
    
    public func fireDisconnectWithError(_ error: String!) {
        delegate?.fastboard?(self, error: .init(type: .disconnected, info: ["info": error]))
    }
    
    public func fireKicked(withReason reason: String!) {
        delegate?.fastboardUserKicked?(self, reason: reason)
    }
    
    public func fireCatchError(whenAppendFrame userId: UInt, error: String!) {
        delegate?.fastboard?(self, warning: ["info": "\(userId), \(error ?? "")"])
    }
    
    public func fireCanRedoStepsUpdate(_ canRedoSteps: Int) {
        delegate?.fastboardCanRedoUpdate?(self, canRedo: canRedoSteps > 0)
    }
    
    public func fireCanUndoStepsUpdate(_ canUndoSteps: Int) {
        delegate?.fastboardCanUndoUpdate?(self, canUndo: canUndoSteps > 0)
    }
}
