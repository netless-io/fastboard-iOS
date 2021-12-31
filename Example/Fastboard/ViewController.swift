//
//  ViewController.swift
//  Fastboard
//
//  Created by yunshi on 12/22/2021.
//  Copyright (c) 2021 yunshi. All rights reserved.
//

import UIKit
import Fastboard
import Whiteboard

class ViewController: UIViewController {
    var board: Fastboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13, *) {
            ThemeManager.shared.theme = DefaultTheme.defaultAutoTheme
        } else {
            // Fallback on earlier versions
            ThemeManager.shared.theme = DefaultTheme.defaultLightTheme
        }
        let f = FastBoardSDK.createFastboardWith(appId: "283/VGiScM9Wiw2HJg",
                                                 roomUUID: "b8a446f06a0411ec8c31196f2bc4a1de",
                                                 roomToken: "WHITEcGFydG5lcl9pZD15TFExM0tTeUx5VzBTR3NkJnNpZz1mZTU3ZTVkNWRlM2Y0NDNlZjNjZjA2MjlhYzExZGY0ZTJlZjhhMzUzOmFrPXlMUTEzS1N5THlXMFNHc2QmY3JlYXRlX3RpbWU9MTY0MDkzMjkwNTQ1NCZleHBpcmVfdGltZT0xNjcyNDY4OTA1NDU0Jm5vbmNlPTE2NDA5MzI5MDU0NTQwMCZyb2xlPXJvb20mcm9vbUlkPWI4YTQ0NmYwNmEwNDExZWM4YzMxMTk2ZjJiYzRhMWRlJnRlYW1JZD05SUQyMFBRaUVldTNPNy1mQmNBek9n",
                                                 userUID: "dfgfdg")
        f.delegate = self
        f.roomDelegate = self
        f.commonDelegate = self
        let board = f.view
        view.addSubview(board)
        board.frame = view.bounds
        
        view.addSubview(btn)
        btn.frame = .init(x: 200, y: 200, width: 66, height: 66)
        
        f.joinRoom { error in
            print(error)
        }
        self.board = f
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    enum TM: CaseIterable, Equatable {
        case light
        case dark
        case auto
    }
    var t: TM = .auto {
        didSet {
            print(t)
            switch t {
            case .light:
                ThemeManager.shared.theme = DefaultTheme.defaultLightTheme
            case .dark:
                ThemeManager.shared.theme = DefaultTheme.defaultDarkTheme
            case .auto:
                if #available(iOS 13, *) {
                    ThemeManager.shared.theme = DefaultTheme.defaultAutoTheme
                } else {
                    return
                }
            }
        }
    }
    
    @objc func onClickUpdateTheme() {
        let all = TM.allCases
        let index = all.firstIndex(of: t)!
        if index == all.count - 1 {
            t = all.first!
        } else {
            t = all[index + 1]
        }
    }
    
    lazy var btn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemOrange
        btn.setTitle("update theme color", for: .normal)
        btn.addTarget(self, action: #selector(onClickUpdateTheme), for: .touchUpInside)
        return btn
    }()
}

extension ViewController: WhiteCommonCallbackDelegate {
    func sdkSetupFail(_ error: Error) {
        
    }
}

extension ViewController: WhiteRoomCallbackDelegate {
    func firePhaseChanged(_ phase: WhiteRoomPhase) {
        print(#function, phase.rawValue)
    }
}

extension ViewController: FastboardDelegate {
    func fastboardUserKickedOut(_ fastboard: Fastboard, reason: String) {
        
    }
    
    func fastboard(_ fastboard: Fastboard, error: FastError) {
    }
}
