//
//  CustomFastboardView.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/1/7.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Whiteboard
import Fastboard
import SnapKit

class CustomFastboardOverlay: FastboardOverlay {
    func updateRoomPhaseUpdate(_ phase: FastRoomPhase) {
        return
    }
    
    func dismissAllSubPanels() {
        return
    }
    
    func invalidAllLayout() {
        return
    }
    
    func updateBoxState(_ state: WhiteWindowBoxState?) {
        return
    }
    
    func updateControlBarLayout(direction: OperationBarDirection) {
        return
    }
    
    func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?, shape: WhiteApplianceShapeTypeKey?) {
        if let appliance = appliance {
            operationsPanel.updateWithApplianceOutside(appliance, shape: shape)
        }
    }
    
    func updateStrokeColor(_ color: UIColor) {
        return
    }
    
    func updateStrokeWidth(_ width: Float) {
        return
    }
    
    func updatePageState(_ state: WhitePageState) {
        return
    }
    
    func updateUndoEnable(_ enable: Bool) {
        return
    }
    
    func updateRedoEnable(_ enable: Bool) {
        return
    }
    
    func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem) {
        return
    }
    
    func setAllPanel(hide: Bool) {
        totalPanels.forEach { $0.view?.isHidden = hide }
    }
    
    func setPanelItemHide(item: DefaultOperationIdentifier, hide: Bool) {
        totalPanels.forEach { $0.setItemHide(fromKey: item, hide: hide)}
    }
    
    func setupWith(room: WhiteRoom, fastboardView: FastboardView, direction: OperationBarDirection) {
        let operationView = operationsPanel.setup(room: room, direction: .horizontal, mask: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        fastboardView.addSubview(operationView)
        operationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(fastboardView.whiteboardView)
        }
    }
    
    var totalPanels: [FastPanel] {
        [operationsPanel]
    }
    
    lazy var operationsPanel = createOperationPanel()
}

extension CustomFastboardOverlay {
    func createOperationPanel() -> FastPanel {
        var items: [FastOperationItem] = []
        items.append(DefaultOperationItem.selectableApplianceItem(.AppliancePencil, shape: nil))
        items.append(DefaultOperationItem.selectableApplianceItem(.ApplianceEraser, shape: nil))
        let panel = FastPanel(items: items)
        return panel
    }
}
