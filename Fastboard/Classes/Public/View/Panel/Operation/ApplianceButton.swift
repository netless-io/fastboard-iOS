//
//  ApplianceButton.swift
//  Fastboard
//
//  Created by xuyunshi on 2022/1/6.
//

import UIKit
import Whiteboard

class PanelItemButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicatorView)
        indicatorView.isHidden = true
    }
    
    override var isSelected: Bool {
        didSet {
            indicatorView.tintColor = isSelected ? iconSelectedColor : iconNormalColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var indicatorInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var hasSubOps: Bool = false {
        didSet {
            indicatorView.isHidden = !hasSubOps
        }
    }
    
    enum Style {
        case selectableAppliance
        case justExecution
        case color(UIColor)
    }
    
    var style: Style = .selectableAppliance {
        didSet {
            tryUpdateStyle()
        }
    }
    
    var rawImage: UIImage? {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var iconHighlightBgColor: UIColor? = nil {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var iconSelectedColor: UIColor? = nil {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var disableColor: UIColor? = nil {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var highlightColor: UIColor? = nil {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var justExecutionNormalColor: UIColor? = nil {
        didSet {
            tryUpdateStyle()
        }
    }
    
    @objc dynamic var iconNormalColor: UIColor? = nil {
        didSet {
            tryUpdateStyle()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                tryUpdateStyle()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let size = indicatorView.image?.size else { return }
        let x = bounds.width - size.width - indicatorInset.right
        let y = bounds.height - size.height - indicatorInset.bottom
        indicatorView.frame = .init(origin: .init(x: x, y: y), size: size)
    }
    
    func tryUpdateStyle() {
        // Throttle
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.updateStyle), object: nil)
        perform(#selector(self.updateStyle), with: nil, afterDelay: 0.3)
    }
    
    func set(rawImage: UIImage,
             drawColor: UIColor,
             backgroundColor: UIColor? = nil,
             cornerRadius: CGFloat = 0,
             state: State) {
        if #available(iOS 13.0, *) {
            let image = rawImage.dynamicDraw(drawColor, backgroundColor: backgroundColor, cornerRadius: cornerRadius, traitCollection: traitCollection)
            setImage(image, for: state)
        } else {
            let image = rawImage.redraw(drawColor, backgroundColor: backgroundColor, cornerRadius: cornerRadius)
            setImage(image.redraw(drawColor), for: state)
        }
    }
    
    @objc func updateStyle() {
        switch style {
        case .selectableAppliance:
            guard let image = rawImage else { return }
            if let normalColor = iconNormalColor {
                set(rawImage: image, drawColor: normalColor, state: .normal)
            }
            if let iconSelectedColor = iconSelectedColor {
                set(rawImage: image, drawColor: iconSelectedColor, state: .selected)
                set(rawImage: image, drawColor: iconSelectedColor, state: [.selected, .highlighted])
            }
            if let highlightColor = highlightColor {
                set(rawImage: image, drawColor: highlightColor, backgroundColor: iconHighlightBgColor, cornerRadius: 5, state: .highlighted)
            }
            if let disableColor = disableColor {
                set(rawImage: image, drawColor: disableColor, state: .disabled)
            }
        case .justExecution:
            guard let image = rawImage else { return }
            if image.renderingMode == .alwaysTemplate,
               let justExecutionNormalColor = justExecutionNormalColor {
                set(rawImage: image, drawColor: justExecutionNormalColor, state: .normal)
                
                if let highlightColor = highlightColor {
                    set(rawImage: image, drawColor: highlightColor, backgroundColor: iconHighlightBgColor, cornerRadius: 5, state: .highlighted)
                }
                if let disableColor = disableColor {
                    set(rawImage: image, drawColor: disableColor, state: .disabled)
                }
            } else {
                setImage(image, for: .normal)
            }
        case .color(let color):
            let normalImage = UIImage.colorItemImage(withColor: color,
                                                     size: .init(width: 24, height: 24),
                                                     radius: 4)
            setImage(normalImage, for: .normal)
            if let iconSelectedColor = iconSelectedColor {
                let selectedImage = UIImage.selectedColorItemImage(withColor: color,
                                                                   size: .init(width: 24, height: 24),
                                                                   radius: 4,
                                                                   borderColor: iconSelectedColor)
                setImage(selectedImage, for: .selected)
            }
            return
        }
    }
    
    lazy var indicatorView: UIImageView = {
        let view = UIImageView(image: UIImage.currentBundle(named: "subops_more"))
        view.transform = .init(scaleX: 1, y: -1)
        return view
    }()
}
