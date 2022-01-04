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
            if let room = room {
                view.setupPanel(room: room)
            }
            initState()
        }
    }
    
    public weak var delegate: FastboardDelegate?
    
    public var commonDelegate: WhiteCommonCallbackDelegate? {
        get { sdkDelegateProxy.target as? WhiteCommonCallbackDelegate }
        set { sdkDelegateProxy.target = newValue }
    }
    
    public var roomDelegate: WhiteRoomCallbackDelegate? {
        get { roomDelegateProxy.target as? WhiteRoomCallbackDelegate }
        set { roomDelegateProxy.target = newValue }
    }
    let roomConfig: WhiteRoomConfig
    
    lazy var roomDelegateProxy = WhiteRoomCallBackDelegateProxy.target(nil, middleMan: self)
    lazy var sdkDelegateProxy = WhiteCommonCallbackDelegateProxy.target(nil, middleMan: self)

    // MARK: - Public
    public func joinRoom(completionHandler: @escaping ((FastError?)->Void)) {
        whiteSDK.joinRoom(with: roomConfig,
                          callbacks: roomDelegateProxy) { [weak self] success, room, error in
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
            room.disableSerialization(false)
            completionHandler(nil)
        }
    }
    
    // MARK: - Private
    func initState() {
        room?.getStateWithResult({ [weak self] state in
            if let appliance = state.memberState?.currentApplianceName {
                self?.view.updateUIWithInitAppliance(appliance)
            } else {
                self?.view.updateUIWithInitAppliance(nil)
            }
            
            if let scene = state.sceneState {
                self?.view.updateSceneState(scene)
            }
            
            if let strokeWidth = state.memberState?.strokeWidth?.floatValue {
                self?.view.updateStrokeWidth(strokeWidth)
            }
            
            if let nums = state.memberState?.strokeColor {
                let color = UIColor.init(numberArray: nums)
                self?.view.updateStrokeColor(color)
            }
        })
    }
    
    init(view: FastboardView, roomConfig: WhiteRoomConfig){
        self.view = view
        self.roomConfig = roomConfig
    }
}

extension Fastboard: WhiteCommonCallbackDelegate {
    public func throwError(_ error: Error) {
    }
    
    public func sdkSetupFail(_ error: Error) {
        delegate?.fastboard(self, error: .init(type: .setupSDK, error: error))
    }
}

extension Fastboard: WhiteRoomCallbackDelegate {
    public func firePhaseChanged(_ phase: WhiteRoomPhase) {
    }
    
    public func fireRoomStateChanged(_ modifyState: WhiteRoomState!) {
        if let sceneState = modifyState.sceneState {
            view.updateSceneState(sceneState)
        }
    }
    
    public func fireDisconnectWithError(_ error: String!) {
        delegate?.fastboard(self, error: .init(type: .disconnected, info: ["info": error]))
    }
    
    public func fireKicked(withReason reason: String!) {
        delegate?.fastboardUserKickedOut(self, reason: reason)
    }
    
    public func fireCanUndoStepsUpdate(_ canUndoSteps: Int) {
        view.updateUndoEnable(canUndoSteps > 0)
    }
    
    public func fireCanRedoStepsUpdate(_ canRedoSteps: Int) {
        view.updateRedoEnable(canRedoSteps > 0)
    }
}
