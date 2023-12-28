//
//  StartViewController.swift
//  Fastboard
//
//  Created by xuyunshi on 2023/12/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Whiteboard

class StartViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func sdf(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if #available(iOS 15.0, *) {
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.rootViewController = HTViewController()
            } else {
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.sdf(sender)
        }
    }
}
