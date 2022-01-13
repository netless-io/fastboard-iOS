//
//  FastOperationItem.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import Foundation
import Whiteboard

@objc
public protocol FastOperationItem: AnyObject {
    var action: ((WhiteRoom, Any?)->Void) { get }
    var room: WhiteRoom? { get set }
    var associatedView: UIView? { get }
    var identifier: String? { get }
    
    func buildView(interrupter: ((FastOperationItem)->Void)?) -> UIView
    func setEnable(_ enable: Bool)
}

public class IndicatorItem: FastOperationItem {
    init(view: UIView, identifier: String) {
        self.associatedView = view
        self.identifier = identifier
    }
    public var action: ((WhiteRoom, Any?) -> Void) = { _, _ in return }
    public var room: WhiteRoom? = nil
    public var associatedView: UIView?
    public var identifier: String?
    public func buildView(interrupter: ((FastOperationItem) -> Void)?) -> UIView {
        return self.associatedView!
    }
    
    public func setEnable(_ enable: Bool) {
        return
    }
}

public class JustExecutionItem: FastOperationItem {
    public init(image: UIImage, action: @escaping ((WhiteRoom, Any?) -> Void), identifier: String?) {
        self.action = action
        self.identifier = identifier
        self.button.rawImage = image
    }
    
    public var identifier: String?
    public var action: ((WhiteRoom, Any?)->Void)
    public weak var associatedView: UIView? { button }
    public weak var room: WhiteRoom? = nil
    var interrupter: ((FastOperationItem)->Void)? = nil
    
    public func setEnable(_ enable: Bool) {
        button.isEnabled = enable
    }
    
    lazy var button: PanelItemButton = {
        let button = PanelItemButton(type: .custom)
        button.style = .justExecution
        button.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        return button
    }()
    
    @objc func onClick() {
        guard let room = room else { return }
        interrupter?(self)
        action(room, nil)
    }
    
    public func buildView(interrupter: ((FastOperationItem)->Void)?) -> UIView {
        self.interrupter = interrupter
        return button
    }
}

public class SliderOperationItem: FastOperationItem {
    public init(value: Float, action: @escaping ((WhiteRoom, Any?) -> Void), sliderConfig: ((UISlider)->Void)?, identifier: String?) {
        self.value = value
        self.action = action
        self.sliderConfig = sliderConfig
        self.identifier = identifier
    }
    
    public var identifier: String?
    var value: Float
    public var action: ((WhiteRoom, Any?)->Void)
    var sliderConfig: ((UISlider)->Void)?
    var interrupter: ((FastOperationItem) -> Void)?
    public weak var associatedView: UIView? { slider }
    public weak var room: WhiteRoom? = nil
    lazy var slider: UISlider = {
        let slider = UISlider(frame: .zero)
        sliderConfig?(slider)
        slider.isContinuous = false
        slider.addTarget(self, action: #selector(onSlider(_:)), for: .valueChanged)
        return slider
    }()
    
    public func setEnable(_ enable: Bool) {
        slider.isEnabled = enable
    }
    
    func syncValueToSlider(_ value: Float) {
        self.value = value
        self.slider.value = value
    }
    
    @objc func onSlider(_ sender: UISlider) {
        guard let room = room else { return }
        self.value = sender.value
        interrupter?(self)
        action(room, sender.value)
    }
    
    public func buildView(interrupter: ((FastOperationItem) -> Void)?) -> UIView {
        self.interrupter = interrupter
        return slider
    }
}

public class ColorItem: FastOperationItem {
    public init(color: UIColor) {
        self.color = color
        self.identifier = color.description
        self.action = {_, _ in}
        self.action = { [weak self] room, _ in
            guard let self = self else { return }
            let state = WhiteMemberState()
            state.strokeColor = self.color.getNumbersArray()
            room.setMemberState(state)
        }
    }
    
    public func setEnable(_ enable: Bool) {
        button.isEnabled = enable
    }
    
    let color: UIColor
    public var room: WhiteRoom?
    var interrupter: ((FastOperationItem)->Void)?
    public var identifier: String?
    public var associatedView: UIView? { button }
    public var action: ((WhiteRoom, Any?) -> Void)
    
    lazy var button: PanelItemButton = {
        let btn = PanelItemButton(type: .custom)
        btn.style = .color(color)
        btn.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        return btn
    }()
    
    @objc func onClick() {
        guard let room = room else { return }
        interrupter?(self)
        button.isSelected = true
        action(room, nil)
    }
    
    public func buildView(interrupter: ((FastOperationItem) -> Void)?) -> UIView {
        self.interrupter = interrupter
        return button
    }
}

public class ApplianceItem: FastOperationItem {
    internal init(image: UIImage, action: @escaping ((WhiteRoom, Any?) -> Void), identifier: String?) {
        self.image = image
        self.action = action
        self.identifier = identifier
    }
    
    public func setEnable(_ enable: Bool) {
        button.isEnabled = enable
    }
    
    public var identifier: String?
    var image: UIImage
    public var action: ((WhiteRoom, Any?)->Void)
    public weak var associatedView: UIView?  { button }
    public weak var room: WhiteRoom? = nil
    var interrupter: ((FastOperationItem)->Void)? = nil
    lazy var button: PanelItemButton = {
        let button = PanelItemButton(type: .custom)
        button.rawImage = image
        button.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc func onClick(_ sender: UIButton) {
        guard let room = room else { return }
        interrupter?(self)
        action(room, nil)
        sender.isSelected = true
    }
    
    public func buildView(interrupter: ((FastOperationItem)->Void)?) -> UIView {
        self.interrupter = interrupter
        return button
    }
}

public class SubOpsItem: NSObject, FastOperationItem {
    @objc
    public init(subOps: [FastOperationItem]) {
        self.subOps = subOps
        self.selectedApplianceItem = subOps.lazy.compactMap { $0 as? ApplianceItem }.first
        self.identifier = subOps.compactMap { $0.identifier }.joined(separator: "-")
    }
    
    public func setEnable(_ enable: Bool) {
        (associatedView as? UIButton)?.isEnabled = enable
    }
    
    func insertItem(_ item: FastOperationItem) {
        subOps.append(item)
        self.identifier = subOps.compactMap { $0.identifier }.joined(separator: "-")
        item.room = room
        let _ = item.buildView { [weak self] item in
            self?.subItemExecuted(subItem: item)
        }
        let newViews = self.enableSubOps
            .compactMap { $0.associatedView }
        self.subPanelView.rebuildFrom(views: newViews)
    }
    
    public var identifier: String?
    var subOps: [FastOperationItem]
    public var action: ((WhiteRoom, Any?)->Void) = {_, _ in }
    public weak var associatedView: UIView? = nil
    public weak var room: WhiteRoom? = nil
    var interrupter: ((FastOperationItem) -> Void)? = nil
    var selectedApplianceItem: ApplianceItem? {
        didSet {
            updateSelectedApplianceItem()
        }
    }
    var selectedColorItem: ColorItem? {
        didSet {
            updateSelectedColorItem()
        }
    }
    
    lazy var subPanelView: SubPanelView = {
        let view = SubPanelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func updateSelectedApplianceAssets() {
        if let selectedApplianceItem = selectedApplianceItem {
            let image = selectedApplianceItem.image
            let btn = associatedView as! PanelItemButton
            btn.rawImage = image
        }
    }
    
    func updateSelectedApplianceItem() {
        updateSelectedApplianceAssets()
        deselectAllApplianceItems()
        if let selectedApplianceItem = selectedApplianceItem {
            selectedApplianceItem.button.isSelected = true
            let btn = associatedView as! PanelItemButton
            btn.isSelected = true
        }
    }
    
    func updateSelectedColorAsset() {
        guard let btn = associatedView as? UIButton,
              let item = selectedColorItem
        else { return }
        if !containsSelectableAppliance {
            let image = UIImage.colorItemImage(withColor: item.color, size: .init(width: 18, height: 18), radius: 4)
            btn.setImage(image, for: .normal)
        }
    }
    
    func updateSelectedColorItem() {
        updateSelectedColorAsset()
        if !containsSelectableAppliance {
            subPanelView.deselectAll()
        }
        (selectedColorItem?.associatedView as? UIButton)?.isSelected = true
    }
    
    func deselectAllApplianceItems() {
        subOps
            .compactMap { $0 as? ApplianceItem }
            .map { $0.button }
            .forEach { $0.isSelected = false }
    }
    
    func deselectAllColorItems() {
        subOps
            .compactMap { $0 as? ColorItem }
            .map { $0.button }
            .forEach { $0.isSelected = false }
    }
    
    var containsSelectableAppliance: Bool {
        subOps.contains(where: {
            $0 is ApplianceItem
        })
    }
    
    @objc func onClick(_ sender: UIButton) {
        guard let room = room else { return }
        interrupter?(self)
        selectedApplianceItem?.action(room, nil)
        
        // Update self UI
        if let _ = selectedApplianceItem {
            updateSelectedApplianceItem()
        }
        if let _ = selectedColorItem {
            updateSelectedColorItem()
        }
        
        (associatedView as? UIButton)?.isSelected = true
        
        func loopForFastboardView(from: UIView) -> FastboardView? {
            var current: UIView? = from
            while current != nil {
                current = current?.superview
                if let current = current as? FastboardView {
                    return current
                }
            }
            return nil
        }
        
        if subPanelView.superview == nil {
            let container = loopForFastboardView(from: associatedView!)
            if let whiteboardView = container!.whiteboardView {
                container?.insertSubview(subPanelView, aboveSubview: whiteboardView)
            } else {
                container?.addSubview(subPanelView)
            }
            subPanelView.exceptView = associatedView
            subPanelView.show()
        } else {
            if subPanelView.isHidden {
                subPanelView.show()
            }
        }
    }
    
    func initButtonInterface(button: PanelItemButton) {
        if let op = subOps.first {
            if let item = op as? ApplianceItem {
                button.rawImage = item.image
                return
            }
            if let item = op as? ColorItem {
                button.setImage(item.button.image(for: .normal)!, for: .normal)
                return
            }
        }
    }
    
    func subItemExecuted(subItem: FastOperationItem) {
        interrupter?(subItem)
        // Update current button image on panel
        if let item = subItem as? ApplianceItem {
            selectedApplianceItem = item
        }
        if let item = subItem as? ColorItem {
            selectedColorItem = item
        }
    }
    
    func configInterfaceForTraitCollectionChanged() {
        if let _ = selectedColorItem {
            updateSelectedColorAsset()
        }
        if let _ = selectedApplianceItem {
            updateSelectedApplianceAssets()
        }
    }
    
    // Filter the single appliance
    // The ops will show on the subpanel
    var enableSubOps: [FastOperationItem] {
        let singleAppliance = subOps.compactMap { $0 as? ApplianceItem }.count == 1
        return subOps.filter {
            if singleAppliance, $0 is ApplianceItem { return false }
            return true
        }
    }
    
    public func buildView(interrupter: ((FastOperationItem) -> Void)?) -> UIView {
        let button = PanelItemButton(type: .custom)
        button.hasSubOps = true
        button.indicatorInset = .init(top: 0, left: 0, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        initButtonInterface(button: button)
        button.traitCollectionUpdateHandler = { [weak self] _ in
            self?.configInterfaceForTraitCollectionChanged()
        }
        self.interrupter = interrupter
        self.associatedView = button
        
        let subOpsView = self.enableSubOps
            .map { subOp -> UIView in
                subOp.room = room
                return subOp.buildView { [weak self] item in
                    self?.subItemExecuted(subItem: item)
                }
            }
        self.subPanelView.setupFromItemViews(views: subOpsView)
        return button
    }
}
