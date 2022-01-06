//
//  DefaultOperationItem.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/31.
//

import Foundation
import Whiteboard

public struct DefaultOperationItem {
    public static var defaultColors: [UIColor] {
        return [
            .init(hexString: "#EC3455"),
            .init(hexString: "#F5AD46"),
            .init(hexString: "#68AB5D"),
            .init(hexString: "#32C5FF"),
            .init(hexString: "#005BF6"),
            .init(hexString: "#6236FF"),
            .init(hexString: "#9E51B6"),
            .init(hexString: "#6D7278")
        ]
    }
    
    public static var defaultCompactAppliance: [WhiteApplianceNameKey] {
        [.ApplianceClicker,
         .ApplianceSelector,
         .AppliancePencil,
         .ApplianceEraser,
         .ApplianceArrow,
         .ApplianceRectangle,
         .ApplianceEllipse]
    }
    
    public static func defaultColorItems() -> [FastOperationItem] {
        defaultColors.map { ColorItem(color: $0) }
    }
    
    public static func clean() -> FastOperationItem {
        let image = UIImage.currentBundle(named: "whiteboard_clean")!
        return JustExecutionItem(image: image,
                          action: { room, _ in room.cleanScene(true) },
                          identifier: "clean")
    }
    
    public static let deleteSelectionIdentifier = "deleteSelection"
    public static func deleteSelectionItem() -> FastOperationItem {
        let image = UIImage.currentBundle(named: "whiteboard_remove_selection")?.redraw(.systemRed)
        return JustExecutionItem(image: image!,
                          action: { room, _ in room.deleteOperation() },
                                 identifier: deleteSelectionIdentifier)
    }
    
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
        }, identifier: "strokeWidth")
    }
    
    public static let redoIdentifier = "redo"
    public static func redoItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "whiteboard_redo")!,
                          action: { room, _ in
            room.redo()
        }, identifier: redoIdentifier)
    }
    
    public static let unoIdentifier = "undo"
    public static func undoItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "whiteboard_undo")!,
                          action: { room, _ in
            room.undo()
        }, identifier: unoIdentifier)
    }
    
    
    public static let previousPageIdentifier = "previous"
    public static func previousPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_previous")!,
                          action: { room, _ in
            room.pptPreviousStep()
        }, identifier: previousPageIdentifier)
    }
    
    public static let nextPageIdentifier = "next"
    public static func nextPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_next")!,
                          action: { room, _ in
            room.pptNextStep()
        }, identifier: nextPageIdentifier)
    }
    
    public static let newPageIdentifier = "new"
    public static func newPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_new")!,
                          action: { room, _ in
            let index = room.sceneState.index
            let nextIndex = UInt(index + 1)
            room.putScenes("/", scenes: [WhiteScene()], index: nextIndex)
            room.setSceneIndex(nextIndex, completionHandler: nil)
        }, identifier: newPageIdentifier)
    }
    
    public static func selectableApplianceItem(_ appliance: WhiteApplianceNameKey,
                                               shape: WhiteApplianceShapeTypeKey? = nil) -> FastOperationItem {
        var name = "whiteboard_"
        if appliance == .ApplianceShape, let shape = shape {
            name = name + "shape_\(shape.rawValue)"
        } else {
            name += appliance.rawValue
        }
        let identifier = identifierFor(appliance: appliance, withShapeKey: shape)
        return ApplianceItem(image: UIImage.currentBundle(named: name)!, action: { room, _ in
            let memberState = WhiteMemberState()
            memberState.currentApplianceName = appliance
            memberState.shapeType = shape
            room.setMemberState(memberState)
        }, identifier: identifier)
    }
    
    public static let pageIndicatorIdentifier = "pageIndicator"
    public static func pageIndicatorItem() -> FastOperationItem {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return IndicatorItem(view: label, identifier: pageIndicatorIdentifier)
    }
}

func identifierFor(appliance: WhiteApplianceNameKey, withShapeKey shape: WhiteApplianceShapeTypeKey?) -> String {
    if let shape = shape {
        return appliance.rawValue + "_\(shape.rawValue)"
    } else {
        return appliance.rawValue
    }
}
