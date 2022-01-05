//
//  CompactFastboardView.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/4.
//

import Foundation
import Whiteboard

class CompactFastboardView: FastboardView {
    override func setupPanel(room: WhiteRoom) {
        let colorView = colorAndStrokePanel.setup(room: room)
        let operationView = operationPanel.setup(room: room)
        let deleteView = deleteSelectionPanel.setup(room: room)
        let undoRedoView = undoRedoPanel.setup(room: room,
                                               direction: .horizontal)
        let sceneView = scenePanel.setup(room: room,
                                               direction: .horizontal)
        
        addSubview(colorView)
        addSubview(operationView)
        addSubview(deleteView)
        addSubview(undoRedoView)
        addSubview(sceneView)
            
        let margin: CGFloat = 8
        operationView.leftAnchor.constraint(equalTo: whiteboardView.leftAnchor, constant: margin).isActive = true
        operationView.centerYAnchor.constraint(equalTo: whiteboardView.centerYAnchor).isActive = true
        operationView.translatesAutoresizingMaskIntoConstraints = false
        
        colorView.rightAnchor.constraint(equalTo: operationView.rightAnchor).isActive = true
        colorView.bottomAnchor.constraint(equalTo: operationView.topAnchor, constant: -margin).isActive = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        deleteView.rightAnchor.constraint(equalTo: colorView.rightAnchor).isActive = true
        deleteView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor).isActive = true
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        
        undoRedoView.leftAnchor.constraint(equalTo: whiteboardView.leftAnchor, constant: margin).isActive = true
        undoRedoView.bottomAnchor.constraint(equalTo: whiteboardView.bottomAnchor, constant: -margin).isActive = true
        undoRedoView.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.centerXAnchor.constraint(equalTo: whiteboardView.centerXAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: whiteboardView.bottomAnchor, constant: -margin).isActive = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func updateDisplayStyleFromNewOperationItem(_ item: FastOperationItem) {
        if !item.needColor, !item.needDelete {
            updateDisplayStyle(.hideColorAndDelete)
            return
        }
        if item.needColor {
            updateDisplayStyle(.hideDeleteShowColor)
        } else if item.needDelete {
            updateDisplayStyle(.hideColorShowDelete)
        } else {
            updateDisplayStyle(.all)
        }
    }
    
    func updateDisplayStyle(_ style: DisplayStyle) {
        switch style {
        case .all:
            colorAndStrokePanel.view?.isHidden = false
            operationPanel.view?.isHidden = false
            deleteSelectionPanel.view?.isHidden = false
        case .hideColorShowDelete:
            colorAndStrokePanel.view?.isHidden = true
            operationPanel.view?.isHidden = false
            deleteSelectionPanel.view?.isHidden = false
        case .hideDeleteShowColor:
            colorAndStrokePanel.view?.isHidden = false
            operationPanel.view?.isHidden = false
            deleteSelectionPanel.view?.isHidden = true
        case .hideColorAndDelete:
            colorAndStrokePanel.view?.isHidden = true
            operationPanel.view?.isHidden = false
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
        colorAndStrokePanel.updateSelectedColor(color)
    }
    
    override func updateStrokeWidth(_ width: Float) {
        colorAndStrokePanel.updateStrokeWidth(width)
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
    
    enum DisplayStyle {
        case all
        case hideColorShowDelete
        case hideDeleteShowColor
        case hideColorAndDelete
    }

    override var totalPanels: [FastPanel] {
        panels.map { $0.value }
    }
    
    lazy var panels: [PanelKey: FastPanel] = [
        .operations: createOperationPanel(),
        .colorsAndStrokeWidth: createColorAndStrokePanel(),
        .deleteSelection: createDeleteSelectionPanel(),
        .undoRedo: createUndoRedoPanel(),
        .scenes: createScenesPanel()
    ]
}

extension CompactFastboardView {
    enum PanelKey: Equatable {
        case operations
        case deleteSelection
        case colorsAndStrokeWidth
        case undoRedo
        case scenes
    }
    
    var colorAndStrokePanel: FastPanel { panels[.colorsAndStrokeWidth]! }
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
    
    func createColorAndStrokePanel() -> FastPanel {
        var items: [FastOperationItem] = [DefaultOperationItem.strokeWidthItem()]
        items.append(contentsOf: DefaultOperationItem.defaultColorItems())
        let panel = FastPanel(items: [SubOpsItem(subOps: items)])
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
        var ops = DefaultOperationItem.defaultCompactAppliance
                .map {
                    DefaultOperationItem.selectableApplianceItem($0)
                }
        ops.append(DefaultOperationItem.clean())
        let op = SubOpsItem(subOps: ops)
        let panel = FastPanel(items: [op])
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
