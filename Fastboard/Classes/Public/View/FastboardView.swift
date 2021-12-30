//
//  FastboardView.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation
import Whiteboard

@objc public class FastboardView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
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
        
        if let operationBar = operationBar {
//            operationBar.cen
//            operationBar.frame = .init(origin: .zero, size: operationBar.intrinsicContentSize)
        }
    }
    
    func rebuildStyleForBeforeOS12() {
        subviews.forEach { $0.removeFromSuperview() }
        setupViews()
    }
    
    var whiteboardView: WhiteBoardView!
    
    var operationBar: UIView?
    var strokeColorPanelBar: UIView?
    
    lazy var strokeColorPanel = FastPanel(items: [
        strokeAndColor
    ])
    
    lazy var panel = FastPanel(items: [
        subs
    ])
}

extension FastboardView {
    func setupViews() {
        backgroundColor = .systemGray
        whiteboardView = WhiteBoardView()
        whiteboardView.backgroundColor = ThemeManager.shared.colorFor(.background)
        addSubview(whiteboardView)
    }
    
    func setupPanel(room: WhiteRoom) {
        let bar = panel.setup(room: room)
        operationBar = bar
        addSubview(bar)
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.topAnchor.constraint(equalTo: whiteboardView.topAnchor).isActive = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        let strokeColorView = strokeColorPanel.setup(room: room)
        self.strokeColorPanelBar = strokeColorView
        addSubview(strokeColorView)
        strokeColorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        strokeColorView.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        strokeColorView.translatesAutoresizingMaskIntoConstraints = false
    }
}
