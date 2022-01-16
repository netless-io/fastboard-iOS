//
//  Fastboard+Pencil.swift
//  Fastboard
//
//  Created by 许允是 on 2022/1/15.
//

import Foundation
import Whiteboard
import UIKit

extension Fastboard {
    func prepareForSystemPencilBehavior() {
        // Pencil stuff
        updateIfFollowSystemPencilBehavior(FastboardManager.followSystemPencilBehavior)
        NotificationCenter.default.addObserver(self, selector: #selector(pencilFollowBehaviorDidChange), name: pencilBehaviorUpdateNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func onWillResignActiveNotification() {
        view.pencilHandler?.recoverApplianceFromTempRemove()
    }
    
    @objc
    func pencilFollowBehaviorDidChange() {
        updateIfFollowSystemPencilBehavior(FastboardManager.followSystemPencilBehavior)
    }
    
    fileprivate func updateIfFollowSystemPencilBehavior(_ follow: Bool) {
        if #available(iOS 12.1, *) {
            view.isPencilDrawOnly = follow ? UIPencilInteraction.prefersPencilOnlyDrawing : false
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
            view.isPencilDrawOnly = newValue
        }
    }
}

extension Fastboard: UIPencilInteractionDelegate {
    @available(iOS 12.1, *)
    public func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        view.overlay?.respondToPencilTap?(UIPencilInteraction.preferredTapAction)
    }
}
