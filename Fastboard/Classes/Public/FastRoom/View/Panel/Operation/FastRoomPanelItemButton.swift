//
//  FastRoomPanelItemButton.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/6.
//

import UIKit
import Whiteboard

/// Represents a operationItem as a view
public class FastRoomPanelItemButton: UIButton {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicatorView)
        indicatorView.isHidden = true
    }
    
    override public var isSelected: Bool {
        didSet {
            indicatorView.tintColor = isSelected ? iconSelectedColor : iconNormalColor
        }
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public dynamic var indicatorInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var hasSubOps: Bool = false {
        didSet {
            indicatorView.isHidden = !hasSubOps
        }
    }
    
    public enum Style {
        case selectableAppliance
        case justExecution
        case color(UIColor)
    }
    
    public var style: Style = .selectableAppliance {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc
    public var rawImage: UIImage? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc
    public var rawSelectedImage: UIImage? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var selectedColorItemBgColor: UIColor? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var iconHighlightBgColor: UIColor? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var iconSelectedBgColor: UIColor? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var iconSelectedColor: UIColor? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var disableColor: UIColor? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var highlightColor: UIColor? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var justExecutionNormalColor: UIColor? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var iconNormalColor: UIColor? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var selectedBackgroundCornerradius: CGFloat = 0 {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var selectedBackgroundEdgeInset: UIEdgeInsets = .zero {
        didSet {
            tryUpdateStyle()
        }
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                tryUpdateStyle()
            }
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let size = indicatorView.image?.size else { return }
        let x = bounds.width - size.width - indicatorInset.right
        let y = bounds.height - size.height - indicatorInset.bottom
        indicatorView.frame = .init(origin: .init(x: x, y: y), size: size)
    }
    
    func selectedColorItemImage(for color: UIColor) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage.selectedColorItemImage(withColor: color,
                                                  backgroundColor: (selectedColorItemBgColor ?? .clear).resolvedColor(with: traitCollection),
                                                  backgroundCornerRadius: 8)
        }
        return UIImage.selectedColorItemImage(withColor: color,
                                              backgroundColor: selectedColorItemBgColor ?? .clear,
                                              backgroundCornerRadius: 8)
    }
    
    func tryUpdateStyle() {
        // Throttle
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateStyle), object: nil)
        perform(#selector(updateStyle), with: nil, afterDelay: 0.3)
    }
    
    func set(rawImage: UIImage,
             drawColor: UIColor,
             backgroundColor: UIColor? = nil,
             cornerRadius: CGFloat = 0,
             state: State,
             inset: UIEdgeInsets = .zero)
    {
        if #available(iOS 13.0, *) {
            let image = rawImage.dynamicDraw(drawColor, backgroundColor: backgroundColor, cornerRadius: cornerRadius, backgroundEdgeInset: inset, traitCollection: traitCollection)
            setImage(image, for: state)
        } else {
            let image = rawImage.redraw(drawColor, backgroundColor: backgroundColor, cornerRadius: cornerRadius, backgroundEdgeInset: inset)
            setImage(image, for: state)
        }
    }
    
    @objc func updateStyle() {
        indicatorView.tintColor = isSelected ? iconSelectedColor : iconNormalColor
        
        switch style {
        case .selectableAppliance:
            guard let image = rawImage else { return }
            if let normalColor = iconNormalColor {
                set(rawImage: image, drawColor: normalColor, state: .normal)
            }
            
            if let iconSelectedColor {
                if let rawSelectedImage {
                    set(rawImage: rawSelectedImage, drawColor: iconSelectedColor, backgroundColor: iconSelectedBgColor, cornerRadius: selectedBackgroundCornerradius, state: .selected, inset: selectedBackgroundEdgeInset)
                    set(rawImage: rawSelectedImage, drawColor: iconSelectedColor, backgroundColor: iconSelectedBgColor, cornerRadius: selectedBackgroundCornerradius, state: [.selected, .highlighted], inset: selectedBackgroundEdgeInset)
                } else {
                    set(rawImage: image, drawColor: iconSelectedColor, backgroundColor: iconSelectedBgColor, cornerRadius: selectedBackgroundCornerradius, state: .selected, inset: selectedBackgroundEdgeInset)
                    set(rawImage: image, drawColor: iconSelectedColor, backgroundColor: iconSelectedBgColor, cornerRadius: selectedBackgroundCornerradius, state: [.selected, .highlighted], inset: selectedBackgroundEdgeInset)
                }
            }
            
            if let highlightColor {
                set(rawImage: image, drawColor: highlightColor, backgroundColor: iconHighlightBgColor, cornerRadius: 5, state: .highlighted)
            }
            
            if let disableColor {
                set(rawImage: image, drawColor: disableColor, state: .disabled)
            }
        case .justExecution:
            guard let image = rawImage else { return }
            if image.renderingMode == .alwaysTemplate,
               let justExecutionNormalColor
            {
                set(rawImage: image, drawColor: justExecutionNormalColor, state: .normal)
                
                if let highlightColor {
                    set(rawImage: image, drawColor: highlightColor, backgroundColor: iconHighlightBgColor, cornerRadius: 5, state: .highlighted)
                }
                if let disableColor {
                    set(rawImage: image, drawColor: disableColor, state: .disabled)
                }
            } else {
                setImage(image, for: .normal)
            }
        case .color(let color):
            setImage(UIImage.colorItemImageWith(color: color), for: .normal)
            setImage(selectedColorItemImage(for: color), for: .selected)
        }
    }
    
    lazy var indicatorView: UIImageView = {
        let view = UIImageView(image: UIImage.currentBundle(named: "subops_more"))
        view.transform = .init(scaleX: 1, y: -1)
        return view
    }()
}
