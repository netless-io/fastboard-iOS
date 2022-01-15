//
//  Fastboard+Pencil.swift
//  Fastboard
//
//  Created by 许允是 on 2022/1/15.
//

import Foundation
import Whiteboard

extension Fastboard {
    func prepareForPencil() {
        // Pencil stuff
        updateIfFollowSystemPencilBehavior(FastboardManager.followSystemPencilBehavoir)
        NotificationCenter.default.addObserver(self, selector: #selector(pencilFollowBehaviorDidChange), name: pencilBehaviorUpdateNotificationName, object: nil)
    }
    
    func updatePencilBehaviorAfterApplianceChanged(_ new: WhiteApplianceNameKey?) {
        if #available(iOS 12.1, *) {
            view.applyWithPencilDrawOnly(UIPencilInteraction.prefersPencilOnlyDrawing, currentAppliance: new)
        }
    }
    
    @objc
    func pencilFollowBehaviorDidChange() {
        updateIfFollowSystemPencilBehavior(FastboardManager.followSystemPencilBehavoir)
    }
    
    fileprivate func updateIfFollowSystemPencilBehavior(_ follow: Bool) {
        if #available(iOS 12.1, *) {
            view.applyWithPencilDrawOnly(follow ? UIPencilInteraction.prefersPencilOnlyDrawing : false,
                                         currentAppliance: room?.memberState.currentApplianceName)
            if follow {
                if !view.interactions.contains(where: { $0 is UIPencilInteraction }) {
                    let pencil = UIPencilInteraction()
                    pencil.delegate = self
                    view.addInteraction(pencil)
                    UIPencilInteraction.addObserver(self, forKeyPath: "prefersPencilOnlyDrawing", options: .new, context: nil)
                }
            } else {
                if let interation = view.interactions.compactMap({ $0 as? UIPencilInteraction }).first {
                    view.removeInteraction(interation)
                    UIPencilInteraction.removeObserver(self, forKeyPath: "prefersPencilOnlyDrawing")
                }
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "prefersPencilOnlyDrawing", let newValue = change?[.newKey] as? Bool {
            view.applyWithPencilDrawOnly(newValue, currentAppliance: room?.memberState.currentApplianceName)
        }
    }
}

extension Fastboard: UIPencilInteractionDelegate {
    @available(iOS 12.1, *)
    public func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        view.overlay?.respondToPencilTap?(UIPencilInteraction.preferredTapAction)
    }
}
