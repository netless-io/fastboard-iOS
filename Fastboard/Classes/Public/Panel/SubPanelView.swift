//
//  SubPanel.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/30.
//

import Foundation

class SubPanelView: UIView {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds.insetBy(dx: shadowMargin, dy: shadowMargin)
    }
    
    override var intrinsicContentSize: CGSize {
        let maxX = containerView.subviews.map { $0.frame.maxX }.max() ?? 0
        let maxY = containerView.subviews.map { $0.frame.maxY }.max() ?? 0
        return .init(width: maxX + shadowMargin * 2, height: maxY + shadowMargin * 2 )
    }
    
    let shadowMargin: CGFloat = 10
    let maxRowPerLine: CGFloat = 4
    let itemSize: CGSize = .init(width: 44, height: 44)
    
    func setupFromItemViews(views: [UIView]) {
        views.enumerated().forEach { index, view in
            containerView.addSubview(view)
            let rIndex = CGFloat(index % 4)
            let sIndex = CGFloat(index / 4)
            view.frame = .init(x: itemSize.width * rIndex,
                               y: itemSize.height * sIndex,
                               width: itemSize.width,
                               height: itemSize.height)
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
        view.backgroundColor = ThemeManager.shared.colorFor(.background)
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.borderColor = ThemeManager.shared.colorFor(.border)?.cgColor
        view.layer.borderWidth = 1 / UIScreen.main.scale
        return view
    }()
}
