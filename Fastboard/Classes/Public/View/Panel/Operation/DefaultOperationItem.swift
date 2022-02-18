//
//  DefaultOperationItem.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/31.
//

import Foundation
import Whiteboard

@objc
public class DefaultOperationItem: NSObject {
    @objc
    public static var defaultColors: [UIColor] = [
        .init(hexString: "#EC3455"),
        .init(hexString: "#F5AD46"),
        .init(hexString: "#68AB5D"),
        .init(hexString: "#32C5FF"),
        .init(hexString: "#005BF6"),
        .init(hexString: "#6236FF"),
        .init(hexString: "#9E51B6"),
        .init(hexString: "#6D7278")
    ]
    
    static func defaultColorItems() -> [FastOperationItem] {
        defaultColors.map { ColorItem(color: $0) }
    }
    
    @objc
    public static func clean() -> FastOperationItem {
        let image = UIImage.currentBundle(named: "whiteboard_clean")!
        return JustExecutionItem(image: image,
                          action: { room, _ in room.cleanScene(true) },
                                 identifier: DefaultOperationIdentifier.operationType(.clean)!.identifier)
    }
    
    @objc
    public static func deleteSelectionItem() -> FastOperationItem {
        let image = UIImage.currentBundle(named: "whiteboard_remove_selection")?.redraw(.systemRed)
        return JustExecutionItem(image: image!,
                          action: { room, _ in room.deleteOperation() },
                                 identifier: DefaultOperationIdentifier.operationType(.deleteSelection)!.identifier)
    }
    
    @objc
    public static func strokeWidthItem() -> FastOperationItem {
        SliderOperationItem(value: 0,
                            action: { room, s in
            guard let s = s as? Float else { return }
            let memberState = WhiteMemberState()
            memberState.strokeWidth = NSNumber(value: s)
            room.setMemberState(memberState)
        }, sliderConfig: { slider in
            slider.minimumValue = 1
            slider.maximumValue = 20
        }, identifier: DefaultOperationIdentifier.operationType(.strokeWidth)!.identifier)
    }
    
    @objc
    public static func redoItem() -> FastOperationItem {
        let item = JustExecutionItem(image: UIImage.currentBundle(named: "whiteboard_redo")!,
                          action: { room, _ in
            room.redo()
        }, identifier: DefaultOperationIdentifier.operationType(.redo)!.identifier)
        item.button.isEnabled = false
        return item
    }
    
    @objc
    public static func undoItem() -> FastOperationItem {
        let item = JustExecutionItem(image: UIImage.currentBundle(named: "whiteboard_undo")!,
                          action: { room, _ in
            room.undo()
        }, identifier: DefaultOperationIdentifier.operationType(.undo)!.identifier)
        item.button.isEnabled = false
        return item
    }
    
    @objc
    public static func previousPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_previous")!,
                          action: { room, _ in
            let index = room.sceneState.index
            guard index > 0 else { return }
            let previousIndex = UInt(index - 1)
            room.setSceneIndex(previousIndex, completionHandler: nil)
        }, identifier: DefaultOperationIdentifier.operationType(.previousPage)!.identifier)
    }
    
    @objc
    public static func nextPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_next")!,
                          action: { room, _ in
            let index = room.sceneState.index
            guard room.sceneState.scenes.count > index else { return }
            let nextIndex = UInt(index + 1)
            room.setSceneIndex(nextIndex, completionHandler: nil)
        }, identifier: DefaultOperationIdentifier.operationType(.nextPage)!.identifier)
    }
    
    @objc
    public static func newPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_new")!,
                          action: { room, _ in
            let index = room.sceneState.index
            let nextIndex = UInt(index + 1)
            room.putScenes("/", scenes: [WhiteScene()], index: nextIndex)
            room.setSceneIndex(nextIndex, completionHandler: nil)
        }, identifier: DefaultOperationIdentifier.operationType(.newPage)!.identifier)
    }
    
    @objc
    public static func selectableApplianceItem(_ appliance: WhiteApplianceNameKey,
                                               shape: WhiteApplianceShapeTypeKey? = nil) -> FastOperationItem {
        var imageName = "whiteboard_"
        if appliance == .ApplianceShape, let shape = shape {
            imageName = imageName + "shape_\(shape.rawValue)"
        } else {
            imageName += appliance.rawValue
        }
        let identifier = identifierFor(appliance: appliance, withShapeKey: shape)
        return ApplianceItem(image: UIImage.currentBundle(named: imageName)!, action: { room, _ in
            let memberState = WhiteMemberState()
            memberState.currentApplianceName = appliance
            memberState.shapeType = shape
            room.setMemberState(memberState)
        }, identifier: identifier)
    }
    
    @objc
    public static func pageIndicatorItem() -> FastOperationItem {
        let label = PageIndicatorLabel()
        label.textColor = PageIndicatorLabel.appearance().textColor
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return IndicatorItem(view: label,
                             identifier: DefaultOperationIdentifier.operationType(.pageIndicator)!.identifier)
    }
}

func identifierFor(appliance: WhiteApplianceNameKey, withShapeKey shape: WhiteApplianceShapeTypeKey?) -> String {
    DefaultOperationIdentifier.applice(key: appliance, shape: shape).identifier
}
