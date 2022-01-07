//
//  FastPanel.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/31.
//

import Foundation
import Whiteboard

public class FastPanel {
    public init(items: [FastOperationItem]) {
        self.items = items
    }
    public var flatItems: [FastOperationItem] {
        return items
            .map {
                (($0 as? SubOpsItem)?.subOps) ?? []
            }
            .flatMap { $0 }
    }
    public var items: [FastOperationItem]
    weak var delegate: FastPanelDelegate?
    public weak var view: UIView?
    
    public func setItemHide(fromKey key: DefaultOperationKey, hide: Bool) {
        for item in items {
            if item.identifier == key.identifier {
                (item.associatedView)?.isHidden = hide
                // To fetch controlBar
                item.associatedView?.superview?.superview?.invalidateIntrinsicContentSize()
            }
            
            if let subOpsItem = item as? SubOpsItem {
                for op in subOpsItem.subOps {
                    if op.identifier == key.identifier {
                        // To fetch subPanel view
                        op.associatedView?.isHidden = hide
                        (op.associatedView?.superview?.superview as? SubPanelView)?.rebuildLayout()
                        
                        // If the item is the only appliance in this subOps, hide them all
                        if key.selectable, subOpsItem.subOps.filter({ $0 is ApplianceItem }).count == 1 {
                            subOpsItem.associatedView?.isHidden = hide
                        }
                    }
                }
            }
        }
    }
    
    func itemWillBeExecution(_ item: FastOperationItem) {
        if let _ = item as? ApplianceItem {
            deselectAll()
        }
        if let _ = item as? SubOpsItem {
            deselectAll()
        }
        if let colorItem = item as? ColorItem {
            updateSelectedColor(colorItem.color)
        }
        if let strokeWidth = item as? SliderOperationItem {
            updateStrokeWidth(strokeWidth.value)
        }
        delegate?.itemWillBeExecution(fastPanel: self, item: item)
    }
    
    public func deselectAll() {
        items.compactMap { $0.associatedView as? UIButton }.forEach { $0.isSelected = false }
    }
    
    public func updateStrokeWidth(_ width: Float) {
        let sliderOps = items
            .compactMap { $0 as? SubOpsItem }
            .flatMap { $0.subOps }
            .compactMap { $0 as? SliderOperationItem }
        
        sliderOps.forEach {
            $0.syncValueToSlider(width)
        }
    }
    
    public func updateSelectedColor(_ color: UIColor) {
        // Find all the subOps contains color
        let allColorContainers = items
            .compactMap { $0 as? SubOpsItem }
            .filter { $0.subOps.contains(where: { $0 is ColorItem })}
        
        // Update selected color to all the subOps
        allColorContainers.forEach { container in
            let existItem = container.subOps.compactMap { $0 as? ColorItem }.first(where: { $0.color == color })
            if let existItem = existItem {
                container.selectedColorItem = existItem
            } else {
                let newItem = ColorItem(color: color)
                container.insertItem(newItem)
                container.selectedColorItem = newItem
            }
        }
    }
    
    public func updateWithApplianceOutside(_ appliance: WhiteApplianceNameKey, shape: WhiteApplianceShapeTypeKey?) {
        deselectAll()
        let identifier = identifierFor(appliance: appliance, withShapeKey: shape)
        for item in items {
            if let i = item as? ApplianceItem, i.identifier == identifier {
                (i.associatedView as? UIButton)?.isSelected = true
            }
            if let i = item as? SubOpsItem,
               let ids = i.identifier,
               let id = item.identifier,
               ids.contains(id) {
                if let target = i.subOps.first(where: { $0.identifier == identifier }) as? ApplianceItem {
                    i.selectedApplianceItem = target
                }
            }
        }
    }
    
    public func setup(room: WhiteRoom,
               direction: NSLayoutConstraint.Axis = .vertical,
               mask: CACornerMask = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]) -> UIView {
        let views = items.map { item -> UIView in
            item.room = room
            return item.buildView { [weak self] i in
                guard let self = self else { return }
                self.itemWillBeExecution(i)
            }
        }
        let view = ControlBar(direction: direction,
                          borderMask: mask,
                          views: views)
        self.view = view
        return view
    }
}
