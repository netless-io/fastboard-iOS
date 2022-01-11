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

class CustomFastboardView: FastboardView {
    override func setAllPanel(hide: Bool) {
        totalPanels.forEach { $0.view?.isHidden = hide }
    }
    
    override func setPanelItemHide(item: DefaultOperationIdentifier, hide: Bool) {
        totalPanels.forEach { $0.setItemHide(fromKey: item, hide: hide)}
    }
    
    override func setupPanel(room: WhiteRoom) {
        let operationView = operationsPanel.setup(room: room, direction: .horizontal, mask: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        addSubview(operationView)
        operationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.whiteboardView)
        }
    }
    
    override var totalPanels: [FastPanel] {
        [operationsPanel]
    }
    
    lazy var operationsPanel = createOperationPanel()
    
    open override func updateUIWithInitAppliance(_ appliance: WhiteApplianceNameKey?, shape: WhiteApplianceShapeTypeKey?) {
    }
    
    open override func updateStrokeColor(_ color: UIColor) {
    }
    
    open override func updateStrokeWidth(_ width: Float) {
    }
    
    open override func updateSceneState(_ scene: WhiteSceneState) {
    }
    
    open override func itemWillBeExecution(fastPanel: FastPanel, item: FastOperationItem) {
    }
    
    open override func updateUndoEnable(_ enable: Bool) {
    }
    
    open override func updateRedoEnable(_ enable: Bool) {
    }
    
    open override func updateControlBarLayout() {
    }
}

extension CustomFastboardView {
    func createOperationPanel() -> FastPanel {
        var items: [FastOperationItem] = []
        items.append(DefaultOperationItem.selectableApplianceItem(.AppliancePencil, shape: nil))
        items.append(DefaultOperationItem.selectableApplianceItem(.ApplianceEraser, shape: nil))
        let panel = FastPanel(items: items)
        return panel
    }
}
