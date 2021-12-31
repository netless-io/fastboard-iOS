//
//  FastboardView.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation
import Whiteboard

@objc public class FastboardView: UIView, FastThemeChangable {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        whiteboardView.backgroundColor = ThemeManager.shared.colorFor(.background)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Try fill width first
        var width = bounds.width
        var height = width / FastBoardSDK.globalFastboardRatio
        if height > bounds.height {
            height = bounds.height
            width = FastBoardSDK.globalFastboardRatio * height
        }
        let x = (bounds.width - width) / 2
        let y = (bounds.height - height) / 2
        whiteboardView.frame = .init(x: x, y: y, width: width, height: height)
    }
    
    public func rebuildStyleForBeforeOS12() {
        subviews.forEach { $0.removeFromSuperview() }
        setupViews()
        // TODO: Panels
    }
    
    func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?) {
        if let appliance = appliance,
            let item = operationPanel.flatItems.first(where: { $0.identifier == appliance.rawValue }){
            updateDisplayStyleFromNewOperationItem(item)
        } else {
            updateDisplayStyle(.all)
        }
    }
    
    var whiteboardView: WhiteBoardView!
    
    func createDeleteSelectionPanel() -> FastPanel {
        var items: [FastOperationItem] = [DefaultOperationItem.deleteSelectionItem()]
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
    
    var colorAndStrokePanel: FastPanel { panels[.colorsAndStrokeWidth]! }
    var operationPanel: FastPanel { panels[.operations]! }
    var deleteSelectionPanel: FastPanel { panels[.deleteSelection]! }
    
    enum PanelKey: Equatable {
        case operations
        case deleteSelection
        case colorsAndStrokeWidth
    }
    
    lazy var panels: [PanelKey: FastPanel] = [
        .operations: createOperationPanel(),
        .colorsAndStrokeWidth: createColorAndStrokePanel(),
        .deleteSelection: createDeleteSelectionPanel()
    ]
}

extension FastboardView {
    enum DisplayStyle {
        case all
        case hideColorShowDelete
        case hideDeleteShowColor
        case hideColorAndDelete
    }
    
    func setupViews() {
        backgroundColor = .lightGray
        whiteboardView = WhiteBoardView()
        whiteboardView.backgroundColor = ThemeManager.shared.colorFor(.background)
        addSubview(whiteboardView)
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
    
    func setupPanel(room: WhiteRoom) {
        let colorView = colorAndStrokePanel.setup(room: room)
        let operationView = operationPanel.setup(room: room)
        let deleteView = deleteSelectionPanel.setup(room: room)
        
        addSubview(colorView)
        addSubview(operationView)
        addSubview(deleteView)
        
        colorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        colorView.topAnchor.constraint(equalTo: whiteboardView.topAnchor).isActive = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        deleteView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        deleteView.topAnchor.constraint(equalTo: whiteboardView.topAnchor).isActive = true
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        
        operationView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        operationView.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 10).isActive = true
        operationView.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension FastboardView: FastPanelDelegate {
    func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem) {
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
}

extension FastOperationItem {
    var needColor: Bool {
        func applianceNeedColor(_ item: ApplianceItem) -> Bool {
            let needColorKeys: [WhiteApplianceNameKey] = [
                .AppliancePencil,
                .ApplianceText,
                .ApplianceEllipse,
                .ApplianceRectangle,
                .ApplianceStraight,
                .ApplianceArrow,
                .ApplianceShape
            ]
            return needColorKeys.map { $0.rawValue }.contains(item.identifier!)
        }
        if let subOps = self as? SubOpsItem,
           let appliance = subOps.selectedApplianceItem {
            return applianceNeedColor(appliance)
        }
        if let item = self as? ApplianceItem {
            return applianceNeedColor(item)
        }
        return false
    }
    
    var needDelete: Bool {
        func itemNeedDelete(item: FastOperationItem) -> Bool {
            item.identifier == WhiteApplianceNameKey.ApplianceSelector.rawValue
        }
        if let subOps = self as? SubOpsItem,
           let item = subOps.selectedApplianceItem {
            return itemNeedDelete(item: item)
        }
        if let item = self as? ApplianceItem {
            return itemNeedDelete(item: item)
        }
        return false
    }
}
