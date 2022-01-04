//
//  FastboardView.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation
import Whiteboard

@objc public class FastboardView: UIView, FastThemeChangable, FastPanelDelegate {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupWhiteboardView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        whiteboardView.backgroundColor = ThemeManager.shared.colorFor(.background)
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
    
    public func rebuildStyleForBeforeOS12() {
        subviews.forEach { $0.removeFromSuperview() }
        setupWhiteboardView()
        // TODO: Panels
    }
    
    var whiteboardView: WhiteBoardView!
    
    func setupWhiteboardView() {
        backgroundColor = .lightGray
        whiteboardView = WhiteBoardView()
        whiteboardView.backgroundColor = ThemeManager.shared.colorFor(.background)
        addSubview(whiteboardView)
    }
    
    var totalPanels: [FastPanel] {
        fatalError("implement it in subclass")
    }
    
    func setupPanel(room: WhiteRoom) {
        fatalError("implement it in subclass")
    }
    
    func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?) {
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
}
