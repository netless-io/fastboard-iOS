//
//  Theme.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import UIKit

public struct WhiteboardAssets {
    var whiteboardBackgroundColor: UIColor
    var containerColor: UIColor
}

public struct PanelItemAssets {
    var normalIconColor: UIColor
    var selectedIconColor: UIColor
    var highlightBgColor: UIColor
    var subOpsIndicatorColor: UIColor
    var pageTextLabelColor: UIColor
}

public struct ControlBarAssets {
    var backgroundColor: UIColor
    var borderColor: UIColor
    var effectStyle: UIBlurEffect?
}

public protocol ThemeAble {
    var whiteboardAssets: WhiteboardAssets { get }
    var controlBarAssets: ControlBarAssets { get }
    var panelItemAssets: PanelItemAssets { get }
}

public struct ThemeAsset: ThemeAble {
    public var whiteboardAssets: WhiteboardAssets
    public var controlBarAssets: ControlBarAssets
    public var panelItemAssets: PanelItemAssets
}
