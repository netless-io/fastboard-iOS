//
//  FastboardView.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation
import Whiteboard

@objc public enum OperationBarDirection: Int {
    case left = 0
    case right
}

public class FastboardView: UIView, FastPanelDelegate {
    @objc public dynamic var operationBarDirection: OperationBarDirection = .left {
        didSet {
            updateControlBarLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupWhiteboardView()
        setupControlView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func layoutSubviews() {
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
    
    func setupControlView() {
        addSubview(controlViewContainer)
        controlViewContainer.frame = bounds
        controlViewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    var whiteboardView: WhiteBoardView!
    
    public lazy var controlViewContainer = UIView()
    
    func setupWhiteboardView() {
        whiteboardView = WhiteBoardView()
        addSubview(whiteboardView)
    }
    
    var totalPanels: [FastPanel] {
        fatalError("implement it in subclass")
    }
    
    func setupPanel(room: WhiteRoom) {
        fatalError("implement it in subclass")
    }
    
    func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?, shape: WhiteApplianceShapeTypeKey?) {
        fatalError("implement it in subclass")
    }
    
    func updateStrokeColor(_ color: UIColor) {
        fatalError("implement it in subclass")
    }
    
    func updateStrokeWidth(_ width: Float) {
        fatalError("implement it in subclass")
    }
    
    func updateSceneState(_ scene: WhiteSceneState) {
        fatalError("implement it in subclass")
    }
    
    func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem) {
        fatalError("implement it in subclass")
    }
    
    func updateUndoEnable(_ enable: Bool) {
        fatalError("implement it in subclass")
    }
    
    func updateRedoEnable(_ enable: Bool) {
        fatalError("implement it in subclass")
    }
    
    func updateControlBarLayout() {
        fatalError("implement it in subclass")
    }
}

extension FastboardView {
    @objc public dynamic var aa: UIColor {
        get { return .lightGray }
        set { print("haha")}
    }
}
