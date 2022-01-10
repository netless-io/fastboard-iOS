//
//  Fastboard.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import UIKit
import Whiteboard

@objc public class Fastboard: NSObject {
    @objc public let view: FastboardView
    public var whiteSDK: WhiteSDK!
    public var room: WhiteRoom? {
        didSet {
            if let room = room {
                view.setupPanel(room: room)
            }
            initStateAfterJoinRoom()
        }
    }
    
    @objc public weak var delegate: FastboardDelegate?
    
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

    deinit {
        #if DEBUG
        print("fastboard deinit")
        #endif
    }
    
    // MARK: - Public
    @objc public func joinRoom() {
        joinRoom(completionHandler: nil)
    }
    
    public func joinRoom(completionHandler: ((Result<WhiteRoom, FastError>)->Void)? = nil) {
        delegate?.fastboardPhaseDidUpdate(self, phase: .connecting)
        whiteSDK.joinRoom(with: roomConfig,
                          callbacks: roomDelegateProxy) { [weak self] success, room, error in
            guard let self = self else { return }
            if let error = error {
                let fastError = FastError(type: .joinRoom, error: error)
                self.delegate?.fastboard(self, error: fastError)
                completionHandler?(.failure(fastError))
                return
            }
            guard let room = room else {
                let fastError = FastError(type: .joinRoom, info: ["info": "join success without room"])
                self.delegate?.fastboard(self, error: fastError)
                completionHandler?(.failure(fastError))
                return
            }
            self.room = room
            room.disableSerialization(false)
            completionHandler?(.success(room))
        }
    }
    
    // MARK: - Private
    func initStateAfterJoinRoom() {
        guard let state = room?.state else { return }
        if let appliance = state.memberState?.currentApplianceName {
            view.updateUIWithInitAppliance(appliance, shape: state.memberState?.shapeType)
        } else {
            view.updateUIWithInitAppliance(nil, shape: nil)
        }
        
        if let scene = state.sceneState {
            view.updateSceneState(scene)
        }
        
        if let strokeWidth = state.memberState?.strokeWidth?.floatValue {
            view.updateStrokeWidth(strokeWidth)
        }
        
        if let nums = state.memberState?.strokeColor {
            let color = UIColor.init(numberArray: nums)
            view.updateStrokeColor(color)
        }
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
        delegate?.fastboardPhaseDidUpdate(self, phase: .init(rawValue: phase.rawValue) ?? .unknown)
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
