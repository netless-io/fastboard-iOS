//
//  RegularFastboardOverlay.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/11.
//

import Foundation
import Whiteboard

@objc
public class RegularFastboardOverlay: NSObject, FastboardOverlay {
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
        
        operationView.centerYAnchor.constraint(equalTo: fastboardView.whiteboardView.centerYAnchor).isActive = true
        operationView.translatesAutoresizingMaskIntoConstraints = false
        
        deleteView.rightAnchor.constraint(equalTo: operationView.rightAnchor).isActive = true
        deleteView.bottomAnchor.constraint(equalTo: operationView.topAnchor, constant: -margin).isActive = true
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        
        undoRedoView.leftAnchor.constraint(equalTo: fastboardView.whiteboardView.leftAnchor, constant: margin).isActive = true
        undoRedoView.bottomAnchor.constraint(equalTo: fastboardView.whiteboardView.bottomAnchor, constant: -margin).isActive = true
        undoRedoView.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.centerXAnchor.constraint(equalTo: fastboardView.whiteboardView.centerXAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: fastboardView.whiteboardView.bottomAnchor, constant: -margin).isActive = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    public func setPanelItemHide(item: DefaultOperationIdentifier, hide: Bool) {
        panels.values.forEach { $0.setItemHide(fromKey: item, hide: hide)}
    }
    
    public func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem) {
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
            updateDisplayStyle(.all)
        } else {
            updateDisplayStyle(.hideDelete)
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
    
    var operationPanel: FastPanel { panels[.operations]! }
    var deleteSelectionPanel: FastPanel { panels[.deleteSelection]! }
    var undoRedoPanel: FastPanel { panels[.undoRedo]! }
    var scenePanel: FastPanel { panels[.scenes]! }
    
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
        var shapeOps: [FastOperationItem] = [
            DefaultOperationItem.selectableApplianceItem(.ApplianceRectangle),
            DefaultOperationItem.selectableApplianceItem(.ApplianceEllipse),
            DefaultOperationItem.selectableApplianceItem(.ApplianceStraight),
            DefaultOperationItem.selectableApplianceItem(.ApplianceArrow),
            DefaultOperationItem.selectableApplianceItem(.ApplianceShape, shape: .ApplianceShapeTypePentagram),
            DefaultOperationItem.selectableApplianceItem(.ApplianceShape, shape: .ApplianceShapeTypeRhombus),
            DefaultOperationItem.selectableApplianceItem(.ApplianceShape, shape: .ApplianceShapeTypeTriangle),
            DefaultOperationItem.selectableApplianceItem(.ApplianceShape, shape: .ApplianceShapeTypeSpeechBalloon),
            DefaultOperationItem.strokeWidthItem()
        ]
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
