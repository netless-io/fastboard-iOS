//
//  UIColor+Convince.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/2/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init (hexString: String) {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cString.count < 6 {
            self.init(r: 0, g: 0, b: 0, a: 1)
            return
        }
        
        let index = cString.index(cString.endIndex, offsetBy: -6)
        let subString = cString[index...]
        if cString.hasPrefix("0X") { cString = String(subString) }
        if cString.hasPrefix("#") { cString = String(subString) }
        
        if cString.count != 6 {
            self.init(r: 0, g: 0, b: 0, a: 1)
            return
        }
        
        var range: NSRange = NSMakeRange(0, 2)
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt64 = 0x0
        var g: UInt64 = 0x0
        var b: UInt64 = 0x0
        
        Scanner(string: rString).scanHexInt64(&r)
        Scanner(string: gString).scanHexInt64(&g)
        Scanner(string: bString).scanHexInt64(&b)
        
        self.init(r: UInt32(r), g: UInt32(g), b: UInt32(b))
    }
    
    convenience init(r: UInt32 ,g: UInt32 , b: UInt32 , a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: a)
    }
    
    convenience init (numberArray: [NSNumber]){
        let arrayCount = numberArray.count
        guard arrayCount >= 3 else {
            self.init(r: 0, g: 0, b: 0)
            return
        }
        let r = UInt32(truncating: numberArray[0])
        let g = UInt32(truncating: numberArray[1])
        let b = UInt32(truncating: numberArray[2])
        self.init(r: r, g: g, b: b, a: arrayCount >= 4 ? CGFloat(truncating: numberArray[3]) : 1)
    }
    
    func getNumbersArray() -> [NSNumber] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: nil)
        return [NSNumber(value: Int(r * 255)),
                NSNumber(value: Int(g * 255)),
                NSNumber(value: Int(b * 255))]
    }
}
