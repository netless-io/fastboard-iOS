import Fastboard
import Whiteboard

class FTCompactOverlay: CompactFastRoomOverlay {
  override func update(boxState: WhiteWindowBoxState?) {
    let views = [undoRedoPanel.view, scenePanel.view]
    let hide = boxState == .max
    UIView.animate(withDuration: 0.3) {
        views.forEach { $0?.alpha = hide ? 0 : 1 }
    }
  }
  
  override func update(strokeColor: UIColor) {
    if FastRoomDefaultOperationItem.defaultColors.contains(strokeColor) {
      colorAndStrokePanel.updateSelectedColor(strokeColor)
    } else {
      if let rdElement = colorAndStrokePanel.flatItems.compactMap({ $0 as? ColorItem }).randomElement() {
        if let room = rdElement.room {
          rdElement.action(room, nil)
          colorAndStrokePanel.updateSelectedColor(rdElement.color)
        }
      }
    }
  }
}

class FTRegularOverlay: RegularFastRoomOverlay {
  override func update(strokeColor: UIColor) {
    if FastRoomDefaultOperationItem.defaultColors.contains(strokeColor) {
      operationPanel.updateSelectedColor(strokeColor)
    } else {
      if let rdElement = operationPanel.flatItems.compactMap({ $0 as? ColorItem }).randomElement() {
        if let room = rdElement.room {
          rdElement.action(room, nil)
          operationPanel.updateSelectedColor(rdElement.color)
        }
      }
    }
  }
}
