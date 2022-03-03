//
//  Fastboard.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import UIKit
import Whiteboard

/// Representing whiteboard object.
public class Fastboard: NSObject {
    /// The view you should add to your viewController
    @objc
    public let view: FastboardView
    
    /// The whiteSDK object, do not update it's delegate directly
    /// using 'commonDelegate' instead
    @objc
    public var whiteSDK: WhiteSDK!
    
    /// The whiteRoom object, do not update it's delegate directly
    /// using 'roomDelegate' instead
    @objc
    public var room: WhiteRoom? {
        didSet {
            if let room = room {
                view.overlay?.setupWith(room: room, fastboardView: self.view, direction: view.operationBarDirection)
                delegate?.fastboardDidSetupOverlay?(self, overlay: view.overlay)
            }
            initStateAfterJoinRoom()
            if !view.traitCollection.hasCompact {
                view.prepareForPencil()
            }
        }
    }
    
    /// The delegate of fastboard
    /// Wrapped the whiteRoom and whiteSDK event
    @objc
    public weak var delegate: FastboardDelegate?
    
    /// Proxy for whiteSDK delegate
    @objc
    public var commonDelegate: WhiteCommonCallbackDelegate? {
        get { sdkDelegateProxy.target as? WhiteCommonCallbackDelegate }
        set { sdkDelegateProxy.target = newValue }
    }

    /// Proxy for whiteRoom delegate
    @objc
    public var roomDelegate: WhiteRoomCallbackDelegate? {
        get { roomDelegateProxy.target as? WhiteRoomCallbackDelegate }
        set { roomDelegateProxy.target = newValue }
    }
    let roomConfig: WhiteRoomConfig
    
    lazy var roomDelegateProxy = WhiteRoomCallBackDelegateProxy.target(nil, middleMan: self)
    lazy var sdkDelegateProxy = WhiteCommonCallbackDelegateProxy.target(nil, middleMan: self)
    
    // MARK: - Public
    
    /// Call the method to join the whiteRoom
    @objc public func joinRoom() {
        joinRoom(completionHandler: nil)
    }
    
    @objc
    public func disconnectRoom() {
        view.pencilHandler?.recoverApplianceFromTempRemove()
        room?.disconnect(nil)
    }
    
    @objc
    public func updateWritable(_ writable: Bool, completion: ((Error?)->Void)?) {
        room?.setWritable(writable, completionHandler: { [weak room] success, error in
            if success, writable {
                room?.disableSerialization(false)
            }
            completion?(error)
        })
    }
    
    /// Call the method to join the whiteRoom
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
            room.disableSerialization(false)
            self.room = room
            completionHandler?(.success(room))
        }
    }
    
    // MARK: - Private
    func initStateAfterJoinRoom() {
        guard let state = room?.state else { return }
        if let appliance = state.memberState?.currentApplianceName {
            view.overlay?.updateUIWithInitAppliance(appliance, shape: state.memberState?.shapeType)
        } else {
            view.overlay?.updateUIWithInitAppliance(nil, shape: nil)
        }
        
        view.overlay?.updateBoxState(state.windowBoxState)
        
        if let scene = state.sceneState {
            view.overlay?.updateSceneState(scene)
        }
        
        if let strokeWidth = state.memberState?.strokeWidth?.floatValue {
            view.overlay?.updateStrokeWidth(strokeWidth)
        }
        
        if let nums = state.memberState?.strokeColor {
            let color = UIColor.init(numberArray: nums)
            view.overlay?.updateStrokeColor(color)
        }
    }
    
    
    /// Create a Fastboard with FastConfiguration
    /// - Parameter configuration: Configuration for fastboard
    @objc
    public convenience init(configuration: FastConfiguration) {
        func defaultOverlay() -> FastboardOverlay {
            if UIScreen.main.traitCollection.hasCompact {
                return CompactFastboardOverlay()
            } else {
                return RegularFastboardOverlay()
            }
        }
        let fastboardOverlay = configuration.customOverlay ?? defaultOverlay()
        let fastboardView = FastboardView(overlay: fastboardOverlay)
        self.init(view: fastboardView,
                  roomConfig: configuration.whiteRoomConfig,
                  sdkConfig: configuration.whiteSdkConfiguration)
    }
    
    init(view: FastboardView,
         roomConfig: WhiteRoomConfig,
         sdkConfig: WhiteSdkConfiguration){
        self.view = view
        self.roomConfig = roomConfig
        super.init()
        let whiteSDK = WhiteSDK(whiteBoardView: view.whiteboardView,
                                config: sdkConfig,
                                commonCallbackDelegate: self.sdkDelegateProxy)
        self.whiteSDK = whiteSDK
        if !view.traitCollection.hasCompact {
            self.prepareForSystemPencilBehavior()
        }
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
        let fastPhase = FastRoomPhase(rawValue: phase.rawValue) ?? .unknown
        view.overlay?.updateRoomPhaseUpdate(fastPhase)
        delegate?.fastboardPhaseDidUpdate(self, phase: fastPhase)
    }
    
    public func fireRoomStateChanged(_ modifyState: WhiteRoomState!) {
        if let _ = modifyState.memberState {
            view.pencilHandler?.roomApplianceDidUpdate()
        }
        if let sceneState = modifyState.sceneState {
            view.overlay?.updateSceneState(sceneState)
        }
        if let boxState = modifyState.windowBoxState {
            view.overlay?.updateBoxState(boxState)
        }
    }
    
    public func fireDisconnectWithError(_ error: String!) {
        delegate?.fastboard(self, error: .init(type: .disconnected, info: ["info": error ?? ""]))
    }
    
    public func fireKicked(withReason reason: String!) {
        delegate?.fastboardUserKickedOut(self, reason: reason)
    }
    
    public func fireCanUndoStepsUpdate(_ canUndoSteps: Int) {
        view.overlay?.updateUndoEnable(canUndoSteps > 0)
    }
    
    public func fireCanRedoStepsUpdate(_ canRedoSteps: Int) {
        view.overlay?.updateRedoEnable(canRedoSteps > 0)
    }
}
