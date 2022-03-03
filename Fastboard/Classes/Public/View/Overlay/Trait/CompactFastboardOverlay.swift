//
//  CompactFastboardOverlay.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/11.
//

import Foundation
import Whiteboard

/// Overlay for iPhone
public class CompactFastboardOverlay: NSObject, FastboardOverlay, FastPanelDelegate {
    func showReconnectingView(_ show: Bool) {
        if show {
            if reconnectingView.superview == nil {
                operationPanel.view?.superview?.addSubview(reconnectingView)
                reconnectingView.frame = operationPanel.view?.superview?.bounds ?? .zero
                reconnectingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                reconnectingView.activityView.startAnimating()
            } else {
                reconnectingView.activityView.startAnimating()
            }
        } else {
            reconnectingView.removeFromSuperview()
        }
    }
    
    public func updateRoomPhaseUpdate(_ phase: FastRoomPhase) {
        guard FastboardManager.showActivityIndicatorWhenReconnecting else { return }
        switch phase {
        case .reconnecting:
            showReconnectingView(true)
        default:
            showReconnectingView(false)
        }
    }
    
    public func dismissAllSubPanels() {
        panels.forEach { $0.value.dismissAllSubPanels(except: nil)}
    }
    
    @objc
    public static var defaultCompactAppliance: [WhiteApplianceNameKey] = [
        .ApplianceClicker,
        .ApplianceSelector,
        .AppliancePencil,
        .ApplianceEraser,
        .ApplianceArrow,
        .ApplianceRectangle,
        .ApplianceEllipse
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
        return
    }
    
    var allConstraints: [NSLayoutConstraint] = []
    var operationLeftConstraint: NSLayoutConstraint?
    var operationRightConstraint: NSLayoutConstraint?
    
    public func setupWith(room: WhiteRoom, fastboardView: FastboardView, direction: OperationBarDirection) {
        let colorView = colorAndStrokePanel.setup(room: room)
        let operationView = operationPanel.setup(room: room)
        let deleteView = deleteSelectionPanel.setup(room: room)
        let undoRedoView = undoRedoPanel.setup(room: room,
                                               direction: .horizontal)
        let sceneView = scenePanel.setup(room: room,
                                         direction: .horizontal)
        fastboardView.addSubview(colorView)
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
        
        let colorC0 = colorView.rightAnchor.constraint(equalTo: operationView.rightAnchor)
        colorC0.isActive = true
        let colorC1 = colorView.bottomAnchor.constraint(equalTo: operationView.topAnchor, constant: -margin)
        colorC1.isActive = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        let deleteC0 = deleteView.rightAnchor.constraint(equalTo: colorView.rightAnchor)
        deleteC0.isActive = true
        let deleteC1 = deleteView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor)
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
        allConstraints.append(colorC0)
        allConstraints.append(colorC1)
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
        colorAndStrokePanel.updateSelectedColor(color)
    }
    
    public func updateStrokeWidth(_ width: Float) {
        colorAndStrokePanel.updateStrokeWidth(width)
    }
    
    public func updateSceneState(_ scene: WhiteSceneState) {
        if let label = scenePanel.items.first(where: { $0.identifier == DefaultOperationIdentifier.operationType(.pageIndicator)!.identifier })?.associatedView as? UILabel {
            label.text = "\(scene.index + 1) / \(scene.scenes.count)"
            scenePanel.view?.invalidateIntrinsicContentSize()
        }
        if let last = scenePanel.items.first(where: {
            $0.identifier == DefaultOperationIdentifier.operationType(.previousPage)!.identifier
        }) {
            (last.associatedView as? UIButton)?.isEnabled = scene.index > 0
        }
        if let next = scenePanel.items.first(where: {
            $0.identifier == DefaultOperationIdentifier.operationType(.nextPage)!.identifier
        }) {
            (next.associatedView as? UIButton)?.isEnabled = scene.index + 1 < scene.scenes.count
        }
    }
    
    public func updateUndoEnable(_ enable: Bool) {
        undoRedoPanel.items.first(where: { $0.identifier == DefaultOperationIdentifier.operationType(.undo)!.identifier })?.setEnable(enable)
    }
    
    public func updateRedoEnable(_ enable: Bool) {
        undoRedoPanel.items.first(where: { $0.identifier == DefaultOperationIdentifier.operationType(.redo)!.identifier })?.setEnable(enable)
    }
    
    public func setAllPanel(hide: Bool) {
        if hide {
            totalPanels.forEach { $0.view?.isHidden = hide }
        } else {
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
        if item is SubOpsItem {
            // Hide all the other subPanels
            panels.forEach { $0.value.dismissAllSubPanels(except: item)}
        }
        if item is ApplianceItem {
            // If is single, hide all subPanel
            // If has super, hide other subPanel
            let superItem = panels
                .map { $0.value.items }
                .flatMap { $0 }
                .compactMap { $0 as? SubOpsItem }
                .first(where: { $0.subOps.contains { s in
                    s === item
                }})
            panels.forEach { $0.value.dismissAllSubPanels(except: superItem)}
        }
        
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
        case hideColorShowDelete
        case hideDeleteShowColor
        case hideColorAndDelete
    }
    
    func updateDisplayStyleFromNewOperationItem(_ item: FastOperationItem) {
        if !item.needColor, !item.needDelete {
            displayStyle = .hideColorAndDelete
            return
        }
        if item.needColor {
            displayStyle = .hideDeleteShowColor
        } else if item.needDelete {
            displayStyle = .hideColorShowDelete
        } else {
            displayStyle = .all
        }
    }
    
    func updateDisplayStyle(_ style: DisplayStyle) {
        undoRedoPanel.view?.isHidden = false
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
    
    var totalPanels: [FastPanel] {
        panels.map { $0.value }
    }
    
    lazy var panels: [PanelKey: FastPanel] = [
        .operations: createOperationPanel(),
        .colorsAndStrokeWidth: createColorAndStrokePanel(),
        .deleteSelection: createDeleteSelectionPanel(),
        .undoRedo: createUndoRedoPanel(),
        .scenes: createScenesPanel()
    ]
    
    lazy var reconnectingView: ReconnectingView = ReconnectingView()
}

extension CompactFastboardOverlay {
    enum PanelKey: Equatable {
        case operations
        case deleteSelection
        case colorsAndStrokeWidth
        case undoRedo
        case scenes
    }
    
    @objc
    public var colorAndStrokePanel: FastPanel { panels[.colorsAndStrokeWidth]! }
    
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
        var ops = Self.defaultCompactAppliance
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
