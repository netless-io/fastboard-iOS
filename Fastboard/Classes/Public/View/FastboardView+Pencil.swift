//
//  FastboardView+Pencil.swift
//  Fastboard
//
//  Created by 许允是 on 2022/1/15.
//

import Foundation
import Whiteboard

extension FastboardView {
    func applyWithPencilDrawOnly(_ only: Bool, currentAppliance: WhiteApplianceNameKey?) {
        isPencilDrawOnly = only
        if let currentAppliance = currentAppliance {
            syncPencilStatusWithCurrentAppliance(currentAppliance)
        }
    }
    
    /// Call this after webview setup
    func prepareForPencil() {
        getAllPencilRelatedGestures().forEach {
            webPencilableGesture.add($0)
        }
    }
    
    fileprivate func getAllPencilRelatedGestures() -> [UIGestureRecognizer] {
        guard let contentView = whiteboardView?.scrollView.subviews.first(where: { $0.classForCoder.description() == "WKContentView" })
        else { return [] }
        guard let gestures = contentView.gestureRecognizers
        else { return [] }
        let pencilValue = UITouch.TouchType.pencil.rawValue
        return gestures.filter { $0.allowedTouchTypes.contains(where: { $0.intValue == pencilValue })}
    }
    
    fileprivate func syncPencilStatusWithCurrentAppliance(_ appliance: WhiteApplianceNameKey) {
        // Process about pencil
        if appliance == .AppliancePencil {
            applyPencilInteracteOnly(isPencilDrawOnly)
        } else {
            applyPencilInteracteOnly(false)
        }
    }
    
    fileprivate func applyPencilInteracteOnly(_ pencilOnly: Bool) {
        let directTouchValue = UITouch.TouchType.direct.rawValue
        webPencilableGesture.allObjects.enumerated().forEach {
            var types = $0.element.allowedTouchTypes
            if pencilOnly, types.contains(where: { $0.intValue == directTouchValue}) {
                types = types.filter { $0.intValue != directTouchValue}
            } else if !pencilOnly, !types.contains(where: { $0.intValue == directTouchValue}) {
                types.append(NSNumber(value: directTouchValue))
            }
            $0.element.allowedTouchTypes = types
        }
    }
}
