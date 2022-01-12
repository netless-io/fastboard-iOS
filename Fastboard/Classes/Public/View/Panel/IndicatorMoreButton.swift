//
//  IndicatorMoreButton.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/30.
//

import Foundation

class IndicatorMoreButton: UIButton {
    var indicatorInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let size = indicatorView.image?.size else { return }
        let x = bounds.width - size.width - indicatorInset.right
        let y = bounds.height - size.height - indicatorInset.bottom
        indicatorView.frame = .init(origin: .init(x: x, y: y), size: size)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicatorView)
        syncIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var isSelected: Bool {
        didSet {
//            syncIndicator()
        }
    }
    
    func syncIndicator() {
//        indicatorView.tintColor = isSelected ? tintColor : ThemeManager.shared.colorFor(<#T##type: ThemeComponentType##ThemeComponentType#>)
    }
    
    lazy var indicatorView: UIImageView = {
        let view = UIImageView(image: UIImage.currentBundle(named: "subops_more"))
        view.transform = .init(scaleX: 1, y: -1)
        return view
    }()
}
