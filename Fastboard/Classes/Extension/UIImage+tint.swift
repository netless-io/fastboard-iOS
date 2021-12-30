//
//  UIImage+tint.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

import UIKit

extension UIImage {
    func redraw(_ color: UIColor,
                   backgroundColor: UIColor? = nil,
                   cornerRadius: CGFloat = 0,
                   backgroundEdgeInset: UIEdgeInsets = .zero) -> UIImage {
        let rect = CGRect(origin: .zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        var bg: UIImage?
        // Draw background
        if let bgColor = backgroundColor {
            context?.setFillColor(bgColor.cgColor)
            let bgRect = rect.inset(by: backgroundEdgeInset)
            let path = UIBezierPath(roundedRect: bgRect, cornerRadius: cornerRadius)
            path.fill()
            context?.fillPath()
            bg = UIGraphicsGetImageFromCurrentImageContext()
            context?.clear(rect)
        }
        // Draw icon
        draw(in: rect)
        color.set()
        UIRectFillUsingBlendMode(rect, .sourceAtop)
        let icon = UIGraphicsGetImageFromCurrentImageContext()
        context?.clear(rect)
        // Compose
        bg?.draw(in: rect)
        icon?.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!.withRenderingMode(.alwaysOriginal)
    }

}
