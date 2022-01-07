//
//  FastboardView.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation
import Whiteboard
import UIKit

@objc public enum OperationBarDirection: Int {
    case left = 0
    case right
}

open class FastboardView: UIView, FastPanelDelegate, FastPanelControl {
    @objc open dynamic var operationBarDirection: OperationBarDirection = .left {
        didSet {
            updateControlBarLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupWhiteboardView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Try fill width first
        var width = bounds.width
        var height = width / FastBoardSDK.globalFastboardRatio
        if height > bounds.height {
            height = bounds.height
            width = FastBoardSDK.globalFastboardRatio * height
        }
        let x = (bounds.width - width) / 2
        let y = (bounds.height - height) / 2
        whiteboardView.frame = .init(x: x, y: y, width: width, height: height)
    }
    
    open var whiteboardView: WhiteBoardView!
    
    func setupWhiteboardView() {
        whiteboardView = WhiteBoardView()
        addSubview(whiteboardView)
    }
    
    open var totalPanels: [FastPanel] {
        fatalError("implement it in subclass")
    }
    
    open func setupPanel(room: WhiteRoom) {
        fatalError("implement it in subclass")
    }
    
    open func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?, shape: WhiteApplianceShapeTypeKey?) {
        fatalError("implement it in subclass")
    }
    
    open func updateStrokeColor(_ color: UIColor) {
        fatalError("implement it in subclass")
    }
    
    open func updateStrokeWidth(_ width: Float) {
        fatalError("implement it in subclass")
    }
    
    open func updateSceneState(_ scene: WhiteSceneState) {
        fatalError("implement it in subclass")
    }
    
    open func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem) {
        fatalError("implement it in subclass")
    }
    
    open func updateUndoEnable(_ enable: Bool) {
        fatalError("implement it in subclass")
    }
    
    open func updateRedoEnable(_ enable: Bool) {
        fatalError("implement it in subclass")
    }
    
    open func updateControlBarLayout() {
        fatalError("implement it in subclass")
    }
    
    open func setAllPanel(hide: Bool) {
        fatalError("implement it in subclass")
    }
    
    open func setPanelItemHide(item: DefaultOperationKey, hide: Bool) {
        fatalError("implement it in subclass")
    }
}
