//
//  RegularFastboardView.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/4.
//

import Foundation
import Whiteboard

class RegularFastboardView: FastboardView {
    override func setupPanel(room: WhiteRoom) {
        let operationView = operationPanel.setup(room: room)
        let deleteView = deleteSelectionPanel.setup(room: room)
        let undoRedoView = undoRedoPanel.setup(room: room,
                                               direction: .horizontal)
        let sceneView = scenePanel.setup(room: room,
                                               direction: .horizontal)
        
        addSubview(operationView)
        addSubview(deleteView)
        addSubview(undoRedoView)
        addSubview(sceneView)
            
        let margin: CGFloat = 8
        operationView.leftAnchor.constraint(equalTo: whiteboardView.leftAnchor, constant: margin).isActive = true
        operationView.centerYAnchor.constraint(equalTo: whiteboardView.centerYAnchor).isActive = true
        operationView.translatesAutoresizingMaskIntoConstraints = false
        
        deleteView.rightAnchor.constraint(equalTo: operationView.rightAnchor).isActive = true
        deleteView.bottomAnchor.constraint(equalTo: operationView.topAnchor, constant: -margin).isActive = true
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        
        undoRedoView.leftAnchor.constraint(equalTo: whiteboardView.leftAnchor, constant: margin).isActive = true
        undoRedoView.bottomAnchor.constraint(equalTo: whiteboardView.bottomAnchor, constant: -margin).isActive = true
        undoRedoView.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.centerXAnchor.constraint(equalTo: whiteboardView.centerXAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: whiteboardView.bottomAnchor, constant: -margin).isActive = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem) {
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
    
    override func updateStrokeColor(_ color: UIColor) {
        operationPanel.updateSelectedColor(color)
    }
    
    override func updateStrokeWidth(_ width: Float) {
        operationPanel.updateStrokeWidth(width)
    }
    
    override func updateSceneState(_ scene: WhiteSceneState) {
        if let label = scenePanel.items.first(where: { $0.identifier == DefaultOperationItem.pageIndicatorIdentifier })?.associatedView as? UILabel {
            label.text = "\(scene.index + 1) / \(scene.scenes.count)"
        }
    }
    
    override func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?, shape: WhiteApplianceShapeTypeKey?) {
        if let appliance = appliance {
            operationPanel.updateWithApplianceOutside(appliance, shape: shape)
        }
        if let appliance = appliance,
            let item = operationPanel.flatItems.first(where: { $0.identifier == appliance.rawValue }){
            updateDisplayStyleFromNewOperationItem(item)
        } else {
            updateDisplayStyle(.all)
        }
    }
    
    override func updateUndoEnable(_ enable: Bool) {
        undoRedoPanel.items.first(where: { $0.identifier == DefaultOperationItem.unoIdentifier })?.setEnable(enable)
    }
    
    override func updateRedoEnable(_ enable: Bool) {
        undoRedoPanel.items.first(where: { $0.identifier == DefaultOperationItem.redoIdentifier })?.setEnable(enable)
    }
    
    override var totalPanels: [FastPanel] {
        panels.map { $0.value }
    }
    
    lazy var panels: [PanelKey: FastPanel] = [
        .operations: createOperationPanel(),
        .deleteSelection: createDeleteSelectionPanel(),
        .undoRedo: createUndoRedoPanel(),
        .scenes: createScenesPanel()
    ]
}

extension RegularFastboardView {
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
