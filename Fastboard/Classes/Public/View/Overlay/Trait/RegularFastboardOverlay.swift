//
//  RegularFastboardOverlay.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/11.
//

import Foundation
import Whiteboard

public class RegularFastboardOverlay: NSObject, FastboardOverlay {
    @objc
    public func dismissAllSubPanels() {
        panels.forEach { $0.value.dismissAllSubPanels(except: nil)}
    }
    
    @objc
    public static var customOptionPanel: (()->FastPanel)?
    
    @objc
    public static var shapeItems: [FastOperationItem] = [
        DefaultOperationItem.selectableApplianceItem(.ApplianceRectangle),
        DefaultOperationItem.selectableApplianceItem(.ApplianceEllipse),
        DefaultOperationItem.selectableApplianceItem(.ApplianceStraight),
        DefaultOperationItem.selectableApplianceItem(.ApplianceArrow),
        DefaultOperationItem.selectableApplianceItem(.ApplianceShape, shape: .ApplianceShapeTypePentagram),
        DefaultOperationItem.selectableApplianceItem(.ApplianceShape, shape: .ApplianceShapeTypeRhombus),
        DefaultOperationItem.selectableApplianceItem(.ApplianceShape, shape: .ApplianceShapeTypeTriangle),
        DefaultOperationItem.selectableApplianceItem(.ApplianceShape, shape: .ApplianceShapeTypeSpeechBalloon)
    ]
    
    var displayStyle: DisplayStyle? {
        didSet {
            if let displayStyle = displayStyle {
                updateDisplayStyle(displayStyle)
            }
        }
    }
    
    public func invalidAllLayout() {
        allConstraints.forEach { $0.isActive = false }
        operationLeftConstraint = nil
        operationRightConstraint = nil
    }
    
    public func updateBoxState(_ state: WhiteWindowBoxState?) {
        let views = [undoRedoPanel.view, scenePanel.view]
        let hide = state == .max
        UIView.animate(withDuration: 0.3) {
            views.forEach { $0?.alpha = hide ? 0 : 1 }
        }
    }
    
    var allConstraints: [NSLayoutConstraint] = []
    var operationLeftConstraint: NSLayoutConstraint?
    var operationRightConstraint: NSLayoutConstraint?
    
    public func setupWith(room: WhiteRoom, fastboardView: FastboardView, direction: OperationBarDirection) {
        let operationView = operationPanel.setup(room: room)
        let deleteView = deleteSelectionPanel.setup(room: room)
        let undoRedoView = undoRedoPanel.setup(room: room,
                                               direction: .horizontal)
        let sceneView = scenePanel.setup(room: room,
                                               direction: .horizontal)
        fastboardView.addSubview(operationView)
        fastboardView.addSubview(deleteView)
        fastboardView.addSubview(undoRedoView)
        fastboardView.addSubview(sceneView)
        
        let margin: CGFloat = 8
        operationLeftConstraint = operationView.leftAnchor.constraint(equalTo: fastboardView.whiteboardView.leftAnchor, constant: margin)
        operationRightConstraint = operationView.rightAnchor.constraint(equalTo: fastboardView.whiteboardView.rightAnchor, constant: -margin)
        
        let operationC0 = operationView.centerYAnchor.constraint(equalTo: fastboardView.whiteboardView.centerYAnchor)
        operationC0.isActive = true
        operationView.translatesAutoresizingMaskIntoConstraints = false
        
        let deleteC0 = deleteView.rightAnchor.constraint(equalTo: operationView.rightAnchor)
        deleteC0.isActive = true
        let deleteC1 = deleteView.bottomAnchor.constraint(equalTo: operationView.topAnchor, constant: -margin)
        deleteC1.isActive = true
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        
        let undoRedoC0 = undoRedoView.leftAnchor.constraint(equalTo: fastboardView.whiteboardView.leftAnchor, constant: margin)
        undoRedoC0.isActive = true
        let undoRedoC1 = undoRedoView.bottomAnchor.constraint(equalTo: fastboardView.whiteboardView.bottomAnchor, constant: -margin)
        undoRedoC1.isActive = true
        undoRedoView.translatesAutoresizingMaskIntoConstraints = false
        
        let sceneC0 = sceneView.centerXAnchor.constraint(equalTo: fastboardView.whiteboardView.centerXAnchor)
        sceneC0.isActive = true
        let sceneC1 = sceneView.bottomAnchor.constraint(equalTo: fastboardView.whiteboardView.bottomAnchor, constant: -margin)
        sceneC1.isActive = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        allConstraints.append(operationLeftConstraint!)
        allConstraints.append(operationRightConstraint!)
        allConstraints.append(operationC0)
        allConstraints.append(deleteC0)
        allConstraints.append(deleteC1)
        allConstraints.append(undoRedoC0)
        allConstraints.append(undoRedoC1)
        allConstraints.append(sceneC0)
        allConstraints.append(sceneC1)
        
        updateControlBarLayout(direction: direction)
    }
    
    public func updateControlBarLayout(direction: OperationBarDirection) {
        let isLeft = direction == .left
        if isLeft {
            operationLeftConstraint?.isActive = true
            operationRightConstraint?.isActive = false
        } else {
            operationLeftConstraint?.isActive = false
            operationRightConstraint?.isActive = true
        }
    }
    
    public func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?, shape: WhiteApplianceShapeTypeKey?) {
        if let appliance = appliance {
            operationPanel.updateWithApplianceOutside(appliance, shape: shape)
            
            let identifier = identifierFor(appliance: appliance, withShapeKey: shape)
            if let item = operationPanel.flatItems.first(where: { $0.identifier == identifier }) {
                updateDisplayStyleFromNewOperationItem(item)
            }
        } else {
            updateDisplayStyle(.all)
        }
    }
    
    public func updateStrokeColor(_ color: UIColor) {
        operationPanel.updateSelectedColor(color)
    }
    
    public func updateStrokeWidth(_ width: Float) {
        operationPanel.updateStrokeWidth(width)
    }
    
    public func updateSceneState(_ scene: WhiteSceneState) {
        if let label = scenePanel.items.first(where: { $0.identifier == DefaultOperationIdentifier.operationType(.pageIndicator)!.identifier })?.associatedView as? UILabel {
            label.text = "\(scene.index + 1) / \(scene.scenes.count)"
        }
    }
    
    public func updateUndoEnable(_ enable: Bool) {
        undoRedoPanel.items.first(where: { $0.identifier == DefaultOperationIdentifier.operationType(.undo)!.identifier
        })?.setEnable(enable)
    }
    
    public func updateRedoEnable(_ enable: Bool) {
        undoRedoPanel.items.first(where: { $0.identifier == DefaultOperationIdentifier.operationType(.redo)!.identifier
        })?.setEnable(enable)
    }
    
    public func setAllPanel(hide: Bool) {
        totalPanels.forEach { $0.view?.isHidden = hide }
        if !hide {
            if let displayStyle = displayStyle {
                updateDisplayStyle(displayStyle)
            } else {
                print("error status")
                updateDisplayStyle(.all)
            }
        }
    }
    
    public func setPanelItemHide(item: DefaultOperationIdentifier, hide: Bool) {
        panels.values.forEach { $0.setItemHide(fromKey: item, hide: hide)}
    }
    
    public func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem) {
        // Hide all the other subPanels
        panels.forEach { $0.value.dismissAllSubPanels(except: item)}
        
        if item is JustExecutionItem { return }
        if item is ColorItem { return }
        if item is SliderOperationItem { return }
        if let sub = item as? SubOpsItem {
            if sub.subOps.allSatisfy({ i -> Bool in
                return i is JustExecutionItem || i is ColorItem || i is SliderOperationItem
            }) {
                return
            }
        }
        updateDisplayStyleFromNewOperationItem(item)
    }
    
    enum DisplayStyle {
        case all
        case hideDelete
    }
    
    func updateDisplayStyleFromNewOperationItem(_ item: FastOperationItem) {
        if item.needDelete {
            displayStyle = .all
        } else {
            displayStyle = .hideDelete
        }
    }
    
    func updateDisplayStyle(_ style: DisplayStyle) {
        switch style {
        case .all:
            deleteSelectionPanel.view?.isHidden = false
        case .hideDelete:
            deleteSelectionPanel.view?.isHidden = true
        }
    }
    
    var totalPanels: [FastPanel] { panels.map { $0.value } }
    
    lazy var panels: [PanelKey: FastPanel] = [
        .operations: createOperationPanel(),
        .deleteSelection: createDeleteSelectionPanel(),
        .undoRedo: createUndoRedoPanel(),
        .scenes: createScenesPanel()
    ]
}

extension RegularFastboardOverlay {
    enum PanelKey: Equatable {
        case operations
        case deleteSelection
        case undoRedo
        case scenes
    }
    
    @objc
    public var operationPanel: FastPanel { panels[.operations]! }
    
    @objc
    public var deleteSelectionPanel: FastPanel { panels[.deleteSelection]! }
    
    @objc
    public var undoRedoPanel: FastPanel { panels[.undoRedo]! }
    
    @objc
    public var scenePanel: FastPanel { panels[.scenes]! }
    
    func createDeleteSelectionPanel() -> FastPanel {
        let items: [FastOperationItem] = [DefaultOperationItem.deleteSelectionItem()]
        let panel = FastPanel(items: items)
        panel.delegate = self
        return panel
    }
    
    func createUndoRedoPanel() -> FastPanel {
        let ops = [DefaultOperationItem.undoItem(), DefaultOperationItem.redoItem()]
        let panel = FastPanel(items: ops)
        panel.delegate = self
        return panel
    }
    
    func createOperationPanel() -> FastPanel {
        if let panel = RegularFastboardOverlay.customOptionPanel?() {
            panel.delegate = self
            return panel
        }
        
        var shapeOps: [FastOperationItem] = RegularFastboardOverlay.shapeItems
        shapeOps.append(DefaultOperationItem.strokeWidthItem())
        shapeOps.append(contentsOf: DefaultOperationItem.defaultColorItems())
        let shapes = SubOpsItem(subOps: shapeOps)
        
        var pencilSubOps: [FastOperationItem] = [
            DefaultOperationItem.selectableApplianceItem(.AppliancePencil),
            DefaultOperationItem.strokeWidthItem()
        ]
        pencilSubOps.append(contentsOf: DefaultOperationItem.defaultColorItems())
        let pencilOp = SubOpsItem(subOps: pencilSubOps)
        
        var textSubOps: [FastOperationItem] = [
            DefaultOperationItem.selectableApplianceItem(.ApplianceText)
        ]
        textSubOps.append(contentsOf: DefaultOperationItem.defaultColorItems())
        let textOp = SubOpsItem(subOps: textSubOps)
        
        let ops: [FastOperationItem] = [
            DefaultOperationItem.selectableApplianceItem(.ApplianceClicker),
            DefaultOperationItem.selectableApplianceItem(.ApplianceSelector),
            pencilOp,
            textOp,
            DefaultOperationItem.selectableApplianceItem(.ApplianceEraser),
            shapes,
            DefaultOperationItem.clean()
        ]
        let panel = FastPanel(items: ops)
        panel.delegate = self
        return panel
    }
    
    func createScenesPanel() -> FastPanel {
        let ops = [DefaultOperationItem.previousPageItem(),
                   DefaultOperationItem.pageIndicatorItem(),
                   DefaultOperationItem.nextPageItem(),
                   DefaultOperationItem.newPageItem()]
        let panel = FastPanel(items: ops)
        panel.delegate = self
        return panel
    }
}
