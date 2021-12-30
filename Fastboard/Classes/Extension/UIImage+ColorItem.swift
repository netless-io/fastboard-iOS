//
//  UIImage+ColorItem.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/30.
//

import Foundation

extension UIImage {
    static func colorItemImage(withColor color: UIColor,
                               size: CGSize,
                               radius: CGFloat) -> UIImage? {
        let lineColor: CGColor = UIColor.black.withAlphaComponent(0.24).cgColor
        let lineWidth: CGFloat = 1 / UIScreen.main.scale
        let radius: CGFloat = radius
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let current = UIGraphicsGetCurrentContext()
        current?.setFillColor(color.cgColor)
        let pointRect = CGRect.init(origin: .zero, size: size)
        let bezeier = UIBezierPath(roundedRect: pointRect, cornerRadius: radius)
        current?.addPath(bezeier.cgPath)
        current?.fillPath()
        
        let strokeBezier = UIBezierPath(roundedRect: pointRect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2), cornerRadius: radius)
        current?.beginPath()
        current?.addPath(strokeBezier.cgPath)
        current?.setLineWidth(lineWidth)
        current?.setStrokeColor(lineColor)
        current?.strokePath()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
