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
        JustExecutionItem(image: UIImage.currentBundle(named: "whiteboard_clean")!,
                          action: { room, _ in room.cleanScene(true) },
                          identifier: "clean")
    }
    
    public static func deleteSelectionItem() -> FastOperationItem {
        let image = UIImage.currentBundle(named: "whiteboard_remove_selection")?.redraw(.systemRed)
        return JustExecutionItem(image: image!,
                          action: { room, _ in room.deleteOperation() },
                                 identifier: "deleteSelection")
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
    
    public static func selectableApplianceItem(_ appliance: WhiteApplianceNameKey) -> FastOperationItem {
        ApplianceItem(image: UIImage.currentBundle(named: "whiteboard_\(appliance.rawValue)")!, action: { room, _ in
            let memberState = WhiteMemberState()
            memberState.currentApplianceName = appliance
            room.setMemberState(memberState)
        }, identifier: appliance.rawValue)
    }
    
}
