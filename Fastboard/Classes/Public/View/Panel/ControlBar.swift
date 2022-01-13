//
//  RoomControlBar.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/30.
//

import UIKit

/// All the views inserted in this container should not update the button isHidden property
/// call 'updateButtonHide'
public class ControlBar: UIView {
    @objc
    public dynamic var itemWidth: CGFloat = 40 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @objc
    public dynamic var borderWidth: CGFloat = 1 / UIScreen.main.scale {
        didSet {
            updateMask()
        }
    }
    
    @objc
    public dynamic var commonRadius: CGFloat = 10 {
        didSet {
            updateMask()
        }
    }
    
    @objc
    dynamic override var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
            borderLayer.fillColor = borderColor?.cgColor
        }
    }
    
    enum NarrowStyle {
        case none
        case narrowMoreThan(count: Int)
    }
    
    var manualHideItemViews: [UIView] = []
    
    func updateItemViewHide(_ itemView: UIView, hide: Bool) {
        if hide, !manualHideItemViews.contains(itemView) {
            manualHideItemViews.append(itemView)
        } else if !hide, manualHideItemViews.contains(itemView) {
            manualHideItemViews.removeAll(where: { $0 == itemView })
        }
        itemView.isHidden = hide
        invalidateIntrinsicContentSize()
    }
    
    public override var intrinsicContentSize: CGSize {
        let hideCount = stack.arrangedSubviews.filter { $0.isHidden }.count 
        if stack.axis == .vertical {
            return .init(width: itemWidth, height: itemWidth * CGFloat(stack.arrangedSubviews.count - hideCount))
        } else {
            return .init(width: itemWidth * CGFloat(stack.arrangedSubviews.count - hideCount), height: itemWidth)
        }
    }
    
    @objc
    public var direction: NSLayoutConstraint.Axis {
        didSet {
            stack.axis = direction
        }
    }
    
    @objc
    public var borderMask: CACornerMask {
        didSet {
            updateMask()
        }
    }
    
    let narrowMoreThan: Int
    
    init(direction: NSLayoutConstraint.Axis,
         borderMask: CACornerMask,
         views: [UIView],
         narrowStyle: NarrowStyle = .none) {
        self.direction = direction
        self.borderMask = borderMask
        switch narrowStyle {
        case .none:
            narrowMoreThan = 0
        case .narrowMoreThan(let count):
            narrowMoreThan = count
        }
        super.init(frame: .zero)
        
        let effect: UIBlurEffect = .init(style: .regular)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.frame = bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        updateMask()
        
        autoresizesSubviews = true
        addSubview(stack)
        stack.frame = bounds
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        views.forEach({
            stack.addArrangedSubview($0)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func updateMask() {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.borderWidth = borderWidth
            layer.cornerRadius = commonRadius
            layer.maskedCorners = borderMask
        } else {
            layer.mask = cornerRadiusLayer
            if borderLayer.superlayer == nil {
                layer.addSublayer(borderLayer)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 11.0, *) {

        } else {
            cornerRadiusLayer.frame = bounds
            var corner: UIRectCorner = []
            if borderMask.contains(.layerMinXMinYCorner) {
                corner.insert(.topLeft)
            }
            if borderMask.contains(.layerMaxXMinYCorner) {
                corner.insert(.topRight)
            }
            if borderMask.contains(.layerMinXMaxYCorner) {
                corner.insert(.bottomLeft)
            }
            if borderMask.contains(.layerMaxXMaxYCorner) {
                corner.insert(.bottomRight)
            }
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: .init(width: commonRadius, height: commonRadius))
            cornerRadiusLayer.path = path.cgPath
            
            borderLayer.frame = bounds
            let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth, dy: borderWidth), byRoundingCorners: corner, cornerRadii: .init(width: commonRadius, height: commonRadius))
            path.append(innerPath)
            borderLayer.fillRule = .evenOdd
            borderLayer.path = path.cgPath
        }
    }
    
    @objc func onClickScale(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let isNarrow = sender.isSelected
        if !isNarrow {
            stack.arrangedSubviews.filter { view in
                let btn = view as! UIButton
                return !self.manualHideItemViews.contains(btn)
            }.forEach({
                $0.isHidden = false
            })
        } else {
            stack.arrangedSubviews
                .filter { view in
                    let btn = view as! UIButton
                    return !self.manualHideItemViews.contains(btn)
                }.enumerated().forEach { i in
                    // The last one can't be hide
                    if i.element === foldButton {
                        i.element.isHidden = false
                        return
                    }
                    i.element.isHidden = i.offset >= narrowMoreThan
                }
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = direction
        stack.spacing = 0
        return stack
    }()
    
    lazy var foldButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(onClickScale), for: .touchUpInside)
        return btn
    }()
    
    lazy var borderLayer = CAShapeLayer()
    lazy var cornerRadiusLayer = CAShapeLayer()
}

