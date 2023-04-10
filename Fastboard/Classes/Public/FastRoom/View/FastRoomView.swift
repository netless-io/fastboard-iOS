//
//  FastRoomView.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation
import Whiteboard
import UIKit

/// Main view for fastboard
public class FastRoomView: UIView, FastPanelControl {
    @objc
    public dynamic var operationBarDirection: OperationBarDirection = .left {
        didSet {
            overlay?.updateControlBarLayout(direction: operationBarDirection)
        }
    }
    
    @objc
    public var overlay: FastRoomOverlay?

    @objc
    public init(overlay: FastRoomOverlay?, customUrl: String?) {
        self.overlay = overlay
        super.init(frame: .zero)
        setupWhiteboardView(customUrl: customUrl)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        whiteboardView.frame = bounds
    }
    
    @objc
    public var whiteboardView: WhiteBoardView!
    
    func setupWhiteboardView(customUrl: String?) {
        if let customUrl {
            whiteboardView = WhiteBoardView(customUrl: customUrl)
        } else {
            whiteboardView = WhiteBoardView()
        }
        addSubview(whiteboardView)
    }
    
    @objc
    public func setAllPanel(hide: Bool) {
        overlay?.setAllPanel(hide: hide)
    }
    
    @objc
    public func setPanelItemHide(item: FastRoomDefaultOperationIdentifier, hide: Bool) {
        overlay?.setPanelItemHide(item: item, hide: hide)
    }
    
    @objc
    public func dismissAllSubPanels() {
        overlay?.dismissAllSubPanels()
    }
}
