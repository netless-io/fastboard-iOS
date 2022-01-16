//
//  FastboardView+Pencil.swift
//  Fastboard
//
//  Created by 许允是 on 2022/1/15.
//

import Foundation
import Whiteboard

extension FastboardView {
    /// Call this after webView setup
    func prepareForPencil() {
        if let gesture = getAllPencilRelatedGestures().first(where: { $0.classForCoder.description() == "UIWebTouchEventsGestureRecognizer" }) {
            pencilHandler = FastboardPencilDrawHandler(room: whiteboardView.room, drawOnlyPencil: isPencilDrawOnly)
            pencilHandler?.originalDelegate = gesture.delegate
            gesture.delegate = pencilHandler
        }
    }
    
    fileprivate func getAllPencilRelatedGestures() -> [UIGestureRecognizer] {
        guard let contentView = whiteboardView?.scrollView.subviews.first(where: { $0.classForCoder.description() == "WKContentView" })
        else { return [] }
        guard let gestures = contentView.gestureRecognizers
        else { return [] }
        let pencilValue = UITouch.TouchType.pencil.rawValue
        return gestures.filter { $0.allowedTouchTypes.contains(where: { $0.intValue == pencilValue })}
    }
}
