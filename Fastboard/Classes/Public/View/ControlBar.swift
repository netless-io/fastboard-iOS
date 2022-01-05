//
//  RoomControlBar.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/30.
//

import UIKit

var globalRoomControlBarItemWidth: CGFloat = 40

/// All the views inserted in this container should not update the button isHidden property
/// call 'updateButtonHide'
class ControlBar: UIView {
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
    
    override var intrinsicContentSize: CGSize {
        let hideCount = manualHideItemViews.count
        if stack.axis == .vertical {
            return .init(width: globalRoomControlBarItemWidth, height: globalRoomControlBarItemWidth * CGFloat(stack.arrangedSubviews.count - hideCount))
        } else {
            return .init(width: globalRoomControlBarItemWidth * CGFloat(stack.arrangedSubviews.count - hideCount), height: globalRoomControlBarItemWidth)
        }
    }
    
    let direction: NSLayoutConstraint.Axis
    let borderMask: CACornerMask
    let narrowMoreThan: Int
    
    init(direction: NSLayoutConstraint.Axis,
         borderMask: CACornerMask,
         views: [UIView],
         narrowStyle: NarrowStyle = .none,
         itemWidth: CGFloat = globalRoomControlBarItemWidth) {
        self.direction = direction
        self.borderMask = borderMask
        switch narrowStyle {
        case .none:
            narrowMoreThan = 0
        case .narrowMoreThan(let count):
            narrowMoreThan = count
        }
        super.init(frame: .zero)
        //        let effect: UIBlurEffect
        //        if #available(iOS 13.0, *) {
        //            effect = .init(style: .systemMaterialLight)
        //        } else {
        //            effect = .init(style: .extraLight)
        //        }
        //        let effectView = UIVisualEffectView(effect: effect)
        //        addSubview(effectView)
        //        effectView.snp.makeConstraints { make in
        //            make.edges.equalToSuperview()
        //        }
        backgroundColor = ThemeManager.shared.colorFor(.background)
        
        clipsToBounds = true
        layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            layer.maskedCorners = borderMask
        } else {
            // TODO: mask
        }
        
        layer.borderColor =  ThemeManager.shared.colorFor(.border)?.cgColor
        layer.borderWidth = 1 / UIScreen.main.scale
        
        autoresizesSubviews = true
        addSubview(stack)
        stack.frame = bounds
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        views.forEach({
            stack.addArrangedSubview($0)
        })
//        if narrowMoreThan > 0 {
//            stack.addArrangedSubview(foldButton)
//            foldButton.widthAnchor.constraint(equalToConstant: itemWidth).isActive = true
//            foldButton.heightAnchor.constraint(equalToConstant: itemWidth).isActive = true
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
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
}

