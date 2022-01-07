//
//  DefaultOperationItem.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/31.
//

import Foundation
import Whiteboard

public enum FastAppliance: String {
    case clicker = "clicker"
    case pencil = "pencil"
    case selector = "selector"
    case text = "text"
    case ellipse = "ellipse"
    case rectangle = "rectangle"
    case eraser = "eraser"
    case straight = "straight"
    case arrow = "arrow"
    case hand = "hand"
    case laserPointer = "laserPointer"
    case shape = "shape"
}

public enum FastShape: String {
    case triangle = "triangle"
    case rhombus = "rhombus"
    case pentagram = "pentagram"
    case speechBalloon = "speechBalloon"
}

public enum DefaultOperationKey: Equatable {
    case appliance(FastAppliance)
    case shape(FastShape)
    case color(UIColor)
    case deleteSelection
    case strokeWidth
    case clean
    case redo
    case undo
    case newPage
    case previousPage
    case nextPage
    case pageIndicator
    
    var selectable: Bool {
        switch self {
        case .appliance, .shape: return true
        default: return false
        }
    }
    
    public static func ==(lhs: DefaultOperationKey, rhs: DefaultOperationKey) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public var identifier: String {
        switch self {
        case .appliance(let fastAppliance):
            return fastAppliance.rawValue
        case .shape(let fastShape):
            return fastShape.rawValue
        case .color(let uIColor):
            return uIColor.getNumbersArray().description
        case .deleteSelection:
            return "deleteSelection"
        case .strokeWidth:
            return "strokeWidth"
        case .clean:
            return "clean"
        case .redo:
            return "redo"
        case .undo:
            return "undo"
        case .newPage:
            return "newPage"
        case .previousPage:
            return "previousPage"
        case .nextPage:
            return "nextPage"
        case .pageIndicator:
            return "pageIndicator"
        }
    }
}

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
                                 identifier: DefaultOperationKey.clean.identifier)
    }
    
    public static func deleteSelectionItem() -> FastOperationItem {
        let image = UIImage.currentBundle(named: "whiteboard_remove_selection")?.redraw(.systemRed)
        return JustExecutionItem(image: image!,
                          action: { room, _ in room.deleteOperation() },
                                 identifier: DefaultOperationKey.deleteSelection.identifier)
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
        }, identifier: DefaultOperationKey.strokeWidth.identifier)
    }
    
    public static func redoItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "whiteboard_redo")!,
                          action: { room, _ in
            room.redo()
        }, identifier: DefaultOperationKey.redo.identifier)
    }
    
    public static func undoItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "whiteboard_undo")!,
                          action: { room, _ in
            room.undo()
        }, identifier: DefaultOperationKey.undo.identifier)
    }
    
    
    public static func previousPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_previous")!,
                          action: { room, _ in
            room.pptPreviousStep()
        }, identifier: DefaultOperationKey.previousPage.identifier)
    }
    
    public static func nextPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_next")!,
                          action: { room, _ in
            room.pptNextStep()
        }, identifier: DefaultOperationKey.nextPage.identifier)
    }
    
    public static func newPageItem() -> FastOperationItem {
        JustExecutionItem(image: UIImage.currentBundle(named: "scene_new")!,
                          action: { room, _ in
            let index = room.sceneState.index
            let nextIndex = UInt(index + 1)
            room.putScenes("/", scenes: [WhiteScene()], index: nextIndex)
            room.setSceneIndex(nextIndex, completionHandler: nil)
        }, identifier: DefaultOperationKey.newPage.identifier)
    }
    
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
    
    public static func pageIndicatorItem() -> FastOperationItem {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return IndicatorItem(view: label,
                             identifier: DefaultOperationKey.pageIndicator.identifier)
    }
}

func identifierFor(appliance: WhiteApplianceNameKey, withShapeKey shape: WhiteApplianceShapeTypeKey?) -> String {
    if let shape = shape, let fShape = FastShape(rawValue: shape.rawValue) {
        return DefaultOperationKey.shape(fShape).identifier
    } else {
        if let fAppliance = FastAppliance(rawValue: appliance.rawValue) {
            return DefaultOperationKey.appliance(fAppliance).identifier
        }
    }
    return ""
}
