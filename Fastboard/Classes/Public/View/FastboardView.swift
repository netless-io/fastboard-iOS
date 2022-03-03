//
//  FastboardView.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation
import Whiteboard
import UIKit

/// Main view for fastboard
public class FastboardView: UIView, FastPanelControl {
    @objc
    public dynamic var operationBarDirection: OperationBarDirection = .left {
        didSet {
            overlay?.updateControlBarLayout(direction: operationBarDirection)
        }
    }
    
    /// Is whiteboard only drawable with pencil
    var isPencilDrawOnly: Bool = false {
        didSet {
            pencilHandler?.drawOnlyPencil = isPencilDrawOnly
        }
    }
    
    var pencilHandler: FastboardPencilDrawHandler?
    
    @objc
    public var overlay: FastboardOverlay?

    @objc
    public init(overlay: FastboardOverlay?) {
        self.overlay = overlay
        super.init(frame: .zero)
        setupWhiteboardView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Try fill width first
        var width = bounds.width
        var height = width / FastboardManager.globalFastboardRatio
        if height > bounds.height {
            height = bounds.height
            width = FastboardManager.globalFastboardRatio * height
        }
        let x = (bounds.width - width) / 2
        let y = (bounds.height - height) / 2
        whiteboardView.frame = .init(x: x, y: y, width: width, height: height)
    }
    
    @objc
    public var whiteboardView: WhiteBoardView!
    
    func setupWhiteboardView() {
        whiteboardView = WhiteBoardView()
        addSubview(whiteboardView)
    }
    
    @objc
    public func setAllPanel(hide: Bool) {
        overlay?.setAllPanel(hide: hide)
    }
    
    @objc
    public func setPanelItemHide(item: DefaultOperationIdentifier, hide: Bool) {
        overlay?.setPanelItemHide(item: item, hide: hide)
    }
    
    @objc
    public func dismissAllSubPanels() {
        overlay?.dismissAllSubPanels()
    }
}
