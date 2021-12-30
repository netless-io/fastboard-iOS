//
//  UIImage+Bundle.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/30.
//

import Foundation

var iconsBundle: Bundle = {
    let path = Bundle(for: FastBoardSDK.self).path(forResource: "Icons", ofType: "bundle")
    return Bundle(path: path!)!
}()

extension UIImage {
    static func currentBundle(named: String) -> UIImage? {
        return UIImage(named: named, in: iconsBundle, compatibleWith: nil)
    }
}
