//
//  UIImage+ColorItem.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/30.
//

import Foundation

private let colorItemSize: CGSize = .init(width: 16, height: 16)
private let colorItemRadius: CGFloat = 8
extension UIImage
{
    static func colorItemImageWith(color: UIColor,
                               size: CGSize = colorItemSize,
                               radius: CGFloat = colorItemRadius) -> UIImage?
    {
        let radius: CGFloat = radius
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let current = UIGraphicsGetCurrentContext()
        current?.setFillColor(color.cgColor)
        let pointRect = CGRect(origin: .zero, size: size)
        let bezier = UIBezierPath(roundedRect: pointRect, cornerRadius: radius)
        current?.addPath(bezier.cgPath)
        current?.fillPath()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func selectedColorItemImage(withColor color: UIColor,
                                       size: CGSize = colorItemSize,
                                       radius: CGFloat = colorItemRadius,
                                       backgroundColor: UIColor,
                                       backgroundCornerRadius: CGFloat) -> UIImage?
    {
        let selectedExpandMargin: CGFloat = 8
        let canvasSize = CGSize(width: size.width + selectedExpandMargin * 2, height: size.height + selectedExpandMargin * 2)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, UIScreen.main.scale)
        let current = UIGraphicsGetCurrentContext()
        
        let backgroundRect = CGRect(origin: .zero, size: canvasSize)
        let backgroundBezier = UIBezierPath(roundedRect: backgroundRect, cornerRadius: backgroundCornerRadius)
        current?.addPath(backgroundBezier.cgPath)
        current?.setFillColor(backgroundColor.cgColor)
        current?.fillPath()
        
        let pointRect = CGRect(origin: .init(x: selectedExpandMargin, y: selectedExpandMargin), size: size)
        let bezier = UIBezierPath(roundedRect: pointRect, cornerRadius: radius)
        current?.addPath(bezier.cgPath)
        current?.setFillColor(color.cgColor)
        current?.fillPath()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
