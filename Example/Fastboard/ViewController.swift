//
//  ViewController.swift
//  Fastboard
//
//  Created by yunshi on 12/22/2021.
//  Copyright (c) 2021 yunshi. All rights reserved.
//

import UIKit
import Fastboard

class ViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscapeRight
    }
    
    var t: ExampleTheme = .auto {
        didSet {
            themeChangeBtn.setTitle("T / \(t)", for: .normal)
            switch t {
            case .light:
                ThemeManager.shared.apply(DefaultTheme.defaultLightTheme)
            case .dark:
                ThemeManager.shared.apply(DefaultTheme.defaultDarkTheme)
            case .auto:
                if #available(iOS 13, *) {
                    ThemeManager.shared.apply(DefaultTheme.defaultAutoTheme)
                } else {
                    return
                }
            }
        }
    }
    
    var board: Fastboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        let f = FastBoardSDK.createFastboardWith(appId: "283/VGiScM9Wiw2HJg",
                                                 roomUUID: "b8a446f06a0411ec8c31196f2bc4a1de",
                                                 roomToken: "WHITEcGFydG5lcl9pZD15TFExM0tTeUx5VzBTR3NkJnNpZz1mZTU3ZTVkNWRlM2Y0NDNlZjNjZjA2MjlhYzExZGY0ZTJlZjhhMzUzOmFrPXlMUTEzS1N5THlXMFNHc2QmY3JlYXRlX3RpbWU9MTY0MDkzMjkwNTQ1NCZleHBpcmVfdGltZT0xNjcyNDY4OTA1NDU0Jm5vbmNlPTE2NDA5MzI5MDU0NTQwMCZyb2xlPXJvb20mcm9vbUlkPWI4YTQ0NmYwNmEwNDExZWM4YzMxMTk2ZjJiYzRhMWRlJnRlYW1JZD05SUQyMFBRaUVldTNPNy1mQmNBek9n",
                                                 userUID: "sdflsjdflljsdfjewpj")
        
        f.delegate = self
        let board = f.view
        view.autoresizesSubviews = true
        view.addSubview(board)
        board.frame = view.bounds
        board.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(stack)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.frame = .init(origin: .init(x: view.bounds.width - 88, y: 10),
                            size: .init(width: 88, height: CGFloat(stack.arrangedSubviews.count * 66)))
        
        f.joinRoom()
        self.board = f
    }
    
    @objc func onClickUpdateDirection() {
        if FastboardView.appearance().operationBarDirection == .left {
            FastboardView.appearance().operationBarDirection = .right
        } else {
            FastboardView.appearance().operationBarDirection = .left
        }
        AppearanceManager.shared.commitUpdate()
    }
    
    @objc func onClickUpdateTheme() {
        let all = ExampleTheme.allCases
        let index = all.firstIndex(of: t)!
        if index == all.count - 1 {
            t = all.first!
        } else {
            let target = all[index + 1]
            if target == .auto {
                if #available(iOS 13, *) {
                    t = target
                } else {
                    t = all.first!
                }
            } else {
                t = target
            }
        }
    }
    
    lazy var stack = UIStackView(arrangedSubviews: [themeChangeBtn, operationDirectionChange])
    
    lazy var themeChangeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemOrange
        btn.setTitle("T / auto", for: .normal)
        btn.addTarget(self, action: #selector(onClickUpdateTheme), for: .touchUpInside)
        return btn
    }()
    
    lazy var operationDirectionChange: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemOrange
        btn.setTitle("OpDirect", for: .normal)
        btn.addTarget(self, action: #selector(onClickUpdateDirection), for: .touchUpInside)
        return btn
    }()
}

extension ViewController: FastboardDelegate {
    func fastboardPhaseDidUpdate(_ fastboard: Fastboard, phase: FastPhase) {
        print(#function, phase)
    }
    
    func fastboardUserKickedOut(_ fastboard: Fastboard, reason: String) {
        print(#function, reason)
    }
    
    func fastboard(_ fastboard: Fastboard, error: FastError) {
        print(#function, error.localizedDescription)
    }
}
