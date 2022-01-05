//
//  SubPanel.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/30.
//

import Foundation

class SubPanelView: UIView, FastThemeChangable {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var inside = self.point(inside: point, with: event)
        if let exceptView = exceptView {
            let p = convert(point, to: exceptView)
            if exceptView.point(inside: p, with: nil) {
                inside = true
            }
        }
        if !inside {
            UIView.animate(withDuration: 0.3) {
                self.isHidden = true
            }
        }
        return super.hitTest(point, with: event)
    }
    
    var exceptView: UIView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .init(width: 0, height: 2.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func rebuildStyleForBeforeOS12() {
        containerView.backgroundColor = ThemeManager.shared.colorFor(.background)
        containerView.layer.borderColor = ThemeManager.shared.colorFor(.border)?.cgColor
        // TODO:
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds.insetBy(dx: shadowMargin, dy: shadowMargin)
        
        if let exceptView = exceptView,
           let window = UIApplication.shared.keyWindow {
            let ef = exceptView.superview!.convert(exceptView.frame, to: window)
            if ef.maxX > window.bounds.width / 2 {
                rightAnchor.constraint(equalTo: exceptView.leftAnchor).isActive = true
                leftAnchor.constraint(equalTo: exceptView.rightAnchor).isActive = false
            } else {
                rightAnchor.constraint(equalTo: exceptView.leftAnchor).isActive = false
                leftAnchor.constraint(equalTo: exceptView.rightAnchor).isActive = true
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let maxX = containerView.subviews.map { $0.frame.maxX }.max() ?? 0
        let maxY = containerView.subviews.map { $0.frame.maxY }.max() ?? 0
        return .init(width: maxX + shadowMargin * 2, height: maxY + shadowMargin * 2 )
    }
    
    let shadowMargin: CGFloat = 10
    let maxRowPerLine: Int = 4
    let itemSize: CGSize = .init(width: 44, height: 44)
    
    func rebuildFrom(views: [UIView]) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        setupFromItemViews(views: views)
    }
    
    func setupFromItemViews(views: [UIView]) {
        var rowIndex: CGFloat = -1
        var lineIndex: CGFloat = -1
        views.enumerated().forEach { index, view in
            if view is UISlider {
                rowIndex = -1
                if rowIndex > 0 {
                    lineIndex += 1
                }
                let slideHeight: CGFloat = 44
                let inset: CGFloat = 8
                let width: CGFloat = itemSize.width * CGFloat(maxRowPerLine) - (2 * inset)
                let y = containerView.subviews.last?.frame.maxY ?? 0
                view.frame = .init(x: inset,
                                   y: y,
                                   width: width,
                                   height: slideHeight)
            } else {
                rowIndex = CGFloat(Int(rowIndex + 1) % maxRowPerLine)
                lineIndex = rowIndex == 0 ? lineIndex + 1 : lineIndex
                let x = rowIndex == 0 ? 0 : (containerView.subviews.last?.frame.maxX ?? 0)
                let y = rowIndex == 0 ? (containerView.subviews.last?.frame.maxY ?? 0) : (containerView.subviews.last?.frame.minY ?? 0)
                view.frame = .init(x: x,
                                   y: y,
                                   width: itemSize.width,
                                   height: itemSize.height)
            }
            containerView.addSubview(view)
        }
        invalidateIntrinsicContentSize()
    }
    
    func deselectAll() {
        containerView.subviews.forEach { ($0 as? UIButton)?.isSelected = false }
    }
    
    func getItemViews() -> [UIView] {
        containerView.subviews
    }
    
    lazy var containerView: UIView = {
        let view = UIView()
        // TODO: this dynamic color function won't be called if view is not add to window.
        view.backgroundColor = ThemeManager.shared.colorFor(.background)
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.borderColor = ThemeManager.shared.colorFor(.border)?.cgColor
        view.layer.borderWidth = 1 / UIScreen.main.scale
        return view
    }()
}
