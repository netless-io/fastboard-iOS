//
//  FastboardManager.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit
import Whiteboard

public class FastboardManager: NSObject {
    /// Change this to update the whiteRoom ratio and whiteboardView ratio
    @objc
    public static var globalFastboardRatio: CGFloat = 16.0 / 9.0
    
    /// Enable default panel animation, default is true
    public static var enablePanelAnimation: Bool = true
}
