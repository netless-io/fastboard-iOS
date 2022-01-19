//
//  FastboardManager.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit
import Whiteboard

let pencilBehaviorUpdateNotificationName = Notification.Name("pencilBehaviorUpdateNotificationName")

public class FastboardManager: NSObject {
    /// Change this to update the whiteRoom ratio and whiteboardView ratio
    @objc
    public static var globalFastboardRatio: CGFloat = 16.0 / 9.0
    
    /// Enable default panel animation, default is true
    public static var enablePanelAnimation: Bool = true
    
    /// Change this value to indicate if pencil will follow the system preference
    /// And this variable will only effect on iPad (Which has no compact sizeClass)
    /// Default is true
    @objc
    public static var followSystemPencilBehavior = true {
        didSet {
            NotificationCenter.default.post(name: pencilBehaviorUpdateNotificationName, object: nil)
        }
    }
    
    /// Indicate whether an UIActivityIndicatorView should be add to Fastboard in bad network environment
    @objc
    public static var showActivityIndicatorWhenReconnecting: Bool = true
}
