//
//  FastOperation.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import Foundation
import Whiteboard

protocol FastOperationItem: AnyObject {
    var action: ((WhiteRoom, Any?)->Void) { get }
    var room: WhiteRoom? { get set }
    var associatedView: UIView? { get }
    var identifier: String? { get }
    
    func buildView(interrupter: ((FastOperationItem)->Void)?) -> UIView
}

class JustExecutionItem: FastOperationItem {
    internal init(image: UIImage, action: @escaping ((WhiteRoom, Any?) -> Void), identifier: String?) {
        self.image = image
        self.action = action
        self.identifier = identifier
    }
    
    var identifier: String?
    var image: UIImage
    var action: ((WhiteRoom, Any?)->Void)
    weak var associatedView: UIView? = nil
    weak var room: WhiteRoom? = nil
    var interrupter: ((FastOperationItem)->Void)? = nil
    
    @objc func onClick() {
        guard let room = room else { return }
        interrupter?(self)
        action(room, nil)
    }
    
    func buildView(interrupter: ((FastOperationItem)->Void)?) -> UIView {
        let button = UIButton(type: .custom)
        let color = ThemeManager.shared.colorFor(.controlNormal)!
        button.tintColor = color
        button.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        button.setImage(image, for: .normal)
        self.interrupter = interrupter
        self.associatedView = button
        return button
    }
}

class SliderOperationItem: FastOperationItem {
    internal init(value: Float, action: @escaping ((WhiteRoom, Any?) -> Void), sliderConfig: ((UISlider)->Void)?, identifier: String?) {
        self.value = value
        self.action = action
        self.sliderConfig = sliderConfig
        self.identifier = identifier
    }
    
    var identifier: String?
    var value: Float
    var action: ((WhiteRoom, Any?)->Void)
    var sliderConfig: ((UISlider)->Void)?
    var interrupter: ((FastOperationItem) -> Void)?
    weak var associatedView: UIView? = nil
    weak var room: WhiteRoom? = nil
    
    @objc func onSlider(_ sender: UISlider) {
        guard let room = room else { return }
        interrupter?(self)
        action(room, sender.value)
    }
    
    func buildView(interrupter: ((FastOperationItem) -> Void)?) -> UIView {
        let slider = UISlider(frame: .zero)
        sliderConfig?(slider)
        slider.addTarget(self, action: #selector(onSlider(_:)), for: .valueChanged)
        self.associatedView = slider
        self.interrupter = interrupter
        return slider
    }
}

class ColorItem: FastOperationItem {
    init(color: UIColor) {
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
    let color: UIColor
    var room: WhiteRoom?
    var interrupter: ((FastOperationItem)->Void)?
    var identifier: String?
    var associatedView: UIView? = nil
    var action: ((WhiteRoom, Any?) -> Void)
    
    @objc func onClick() {
        guard let room = room else { return }
        interrupter?(self)
        (associatedView as? UIButton)?.isSelected = true
        action(room, nil)
    }
    
    func buildView(interrupter: ((FastOperationItem) -> Void)?) -> UIView {
        let btn = UIButton(type: .custom)
        let image = UIImage.colorItemImage(withColor: color, size: .init(width: 20, height: 20), radius: 10)
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        self.interrupter = interrupter
        self.associatedView = btn
        return btn
    }
}

class SelectableItem: FastOperationItem {
    internal init(image: UIImage, action: @escaping ((WhiteRoom, Any?) -> Void), identifier: String?) {
        self.image = image
        self.action = action
        self.identifier = identifier
    }
    
    var identifier: String?
    var image: UIImage
    var action: ((WhiteRoom, Any?)->Void)
    weak var associatedView: UIView? = nil
    weak var room: WhiteRoom? = nil
    var interrupter: ((FastOperationItem)->Void)? = nil
    
    @objc func onClick(_ sender: UIButton) {
        guard let room = room else { return }
        interrupter?(self)
        action(room, nil)
        sender.isSelected = true
    }
    
    
    func buildView(interrupter: ((FastOperationItem)->Void)?) -> UIView {
        let button = UIButton(type: .custom)
        setSelectableStyleFor(button: button, image: image)
        button.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        self.interrupter = interrupter
        self.associatedView = button
        return button
    }
}

func setSelectableStyleFor(button: UIButton, image: UIImage) {
    let normalColor = ThemeManager.shared.colorFor(.controlNormal)!
    button.tintColor = normalColor
    let selectedColor = ThemeManager.shared.colorFor(.controlSelected)!
    let selectedDark = ThemeManager.shared.colorFor(.controlSelectedDark)!
    let bg = ThemeManager.shared.colorFor(.controlSelectedBg)!
    let highlightImage = image.redraw(normalColor,
                                      backgroundColor: bg,
                                      cornerRadius: 5)
    let selectedImage = image.redraw(selectedColor,
                                     backgroundColor: bg,
                                     cornerRadius: 5)
    let selectedHighlight = image.redraw(selectedDark,
                                         backgroundColor: bg,
                                         cornerRadius: 5)
    button.setImage(image, for: .normal)
    button.setImage(selectedImage, for: .selected)
    button.setImage(highlightImage, for: .highlighted)
    button.setImage(selectedHighlight, for: [.highlighted, .selected])
    button.adjustsImageWhenHighlighted = false
}

class SubOpsItem: FastOperationItem {
    init(subOps: [FastOperationItem]) {
        self.subOps = subOps
        self.selectedItem = subOps.lazy.compactMap { $0 as? SelectableItem }.first
        self.identifier = subOps.compactMap { $0.identifier }.joined(separator: "-")
    }
    
    var identifier: String?
    let subOps: [FastOperationItem]
    var action: ((WhiteRoom, Any?)->Void) = {_, _ in }
    weak var associatedView: UIView? = nil
    weak var room: WhiteRoom? = nil
    var interrupter: ((FastOperationItem) -> Void)? = nil
    var selectedItem: SelectableItem? {
        didSet {
            becomeSelected()
        }
    }
    lazy var subPanelView: SubPanelView = {
        let view = SubPanelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func becomeSelected() {
        (associatedView as? UIButton)?.isSelected = true
        subPanelView.deselectAll()
        (selectedItem?.associatedView as? UIButton)?.isSelected = true
        if let selectedItem = selectedItem, let image = image(for: selectedItem) {
            let btn = associatedView as! UIButton
            btn.setImage(image.redraw(ThemeManager.shared.colorFor(.controlNormal)!),
                         for: .normal)
        }
    }
    
    @objc func onClick(_ sender: UIButton) {
        guard let room = room else { return }
        interrupter?(self)
        selectedItem?.action(room, nil)
        (associatedView as? UIButton)?.isSelected = true
        
        if subPanelView.superview == nil {
            UIApplication.shared.keyWindow?.addSubview(subPanelView)
            subPanelView.leftAnchor.constraint(equalTo: associatedView!.rightAnchor).isActive = true
            subPanelView.centerYAnchor.constraint(equalTo: associatedView!.centerYAnchor).isActive = true
            subPanelView.exceptView = associatedView
        }
        subPanelView.isHidden = false
    }
    
    func initImage() -> UIImage? {
        for op in subOps {
            if let item = op as? SelectableItem { return item.image }
            if let item = op as? ColorItem {
                return UIImage.colorItemImage(withColor: item.color, size: .init(width: 20, height: 20), radius: 10)
            }
        }
        return nil
    }
    
    func image(for operation: FastOperationItem) -> UIImage? {
        if let selectable = operation as? SelectableItem {
            return selectable.image
        }
        return nil
    }
    
    func subItemExecuted(subItem: FastOperationItem) {
        if let item = subItem as? SelectableItem {
            selectedItem = item
        }
        if let item = subItem as? ColorItem {
            let btn = associatedView as? UIButton
            let image = UIImage.colorItemImage(withColor: item.color, size: .init(width: 20, height: 20), radius: 10)
            btn?.setImage(image, for: .normal)
        }
    }
    
    func buildView(interrupter: ((FastOperationItem) -> Void)?) -> UIView {
        let button = IndicatorMoreButton(type: .custom)
        button.indicatorInset = .init(top: 8, left: 0, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        if let image = initImage() {
            button.setImage(image, for: .normal)
        }
        self.interrupter = interrupter
        self.associatedView = button
        let subOpsView = self.subOps.map { subOp -> UIView in
            subOp.room = room
            return subOp.buildView { [weak self] item in
                self?.subItemExecuted(subItem: item)
            }
        }
        self.subPanelView.setupFromItemViews(views: subOpsView)
        return button
    }
}

class FastPanel {
    internal init(items: [FastOperationItem]) {
        self.items = items
    }
    let items: [FastOperationItem]
    
    func itemWillBeExecution(_ item: FastOperationItem) {
        if let _ = item as? SelectableItem {
            deselectAll()
        }
        if let _ = item as? SubOpsItem {
            deselectAll()
        }
    }
    
    func deselectAll() {
        items.compactMap { $0.associatedView as? UIButton }.forEach { $0.isSelected = false }
    }
    
    func updateWithApplianceOutside(_ appliance: WhiteApplianceNameKey) {
        deselectAll()
        for item in items {
            if let i = item as? SelectableItem, i.identifier == appliance.rawValue {
                (i.associatedView as? UIButton)?.isSelected = true
            }
            if let i = item as? SubOpsItem,
               let ids = i.identifier,
               let id = item.identifier,
               ids.contains(id) {
                if let target = i.subOps.first(where: { $0.identifier == appliance.rawValue}) as? SelectableItem {
                    i.selectedItem = target
                }
            }
        }
    }
    
    func setup(room: WhiteRoom) -> UIView {
        let views = items.map { item -> UIView in
            item.room = room
            return item.buildView { [weak self] i in
                guard let self = self else { return }
                self.itemWillBeExecution(i)
            }
        }
        return ControlBar(direction: .vertical,
                          borderMask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner],
                          views: views)
    }
}

let clean = JustExecutionItem(image: UIImage.currentBundle(named: "whiteboard_clean")!,
                              action: { room, _ in room.cleanScene(true) },
                              identifier: "clean")
let strokeWidthItem = SliderOperationItem(value: 0,
                                          action: { room, s in
    guard let s = s as? CGFloat else { return }
    let memberState = WhiteMemberState()
    memberState.strokeWidth = NSNumber(value: s)
    room.setMemberState(memberState)
}, sliderConfig: { slider in
    return
}, identifier: "strokeWidth")

func selectableApplianceItem(_ appliance: WhiteApplianceNameKey) -> FastOperationItem {
    return SelectableItem(image: UIImage.currentBundle(named: "whiteboard_\(appliance.rawValue)")!, action: { room, _ in
        let memberState = WhiteMemberState()
        memberState.currentApplianceName = appliance
        room.setMemberState(memberState)
    }, identifier: appliance.rawValue)
}

let strokeAndColor = SubOpsItem(subOps: [strokeWidthItem, ColorItem(color: .red), ColorItem(color: .black)])

let subs = SubOpsItem(subOps: [selectableApplianceItem(.ApplianceClicker),
                               selectableApplianceItem(.ApplianceSelector),
                               selectableApplianceItem(.AppliancePencil),
                               selectableApplianceItem(.ApplianceEraser),
                               selectableApplianceItem(.ApplianceArrow),
                               selectableApplianceItem(.ApplianceRectangle),
                               selectableApplianceItem(.ApplianceEllipse),
                               clean])
