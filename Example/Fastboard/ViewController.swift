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
        ThemeManager.shared.theme = DefaultTheme.defaultLightTheme
        let f = FastBoardSDK.createFastboardWith(appId: "283/VGiScM9Wiw2HJg",
                                                 roomUUID: "30715df0686e11eca8109f3f1b84a863",
                                                 roomToken: "WHITEcGFydG5lcl9pZD15TFExM0tTeUx5VzBTR3NkJnNpZz0yZTc1MTQzMDFlODQ2ZDNmMTU1YmQ2NjI2NWQxMDFjNGFiNGJjMDQ0OmFrPXlMUTEzS1N5THlXMFNHc2QmY3JlYXRlX3RpbWU9MTY0MDc1ODMwMTI5MiZleHBpcmVfdGltZT0xNjcyMjk0MzAxMjkyJm5vbmNlPTE2NDA3NTgzMDEyOTIwMCZyb2xlPXJvb20mcm9vbUlkPTMwNzE1ZGYwNjg2ZTExZWNhODEwOWYzZjFiODRhODYzJnRlYW1JZD05SUQyMFBRaUVldTNPNy1mQmNBek9n",
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
    
    @objc func onClickUpdateTheme() {
//        let map: [ThemeComponentType: UIColor] = [
//            .background: .cyan
//        ]
//        ThemeManager.shared.theme = { type, collection in
//            return map[type]!
//        }
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
    }
}

extension ViewController: FastboardDelegate {
    func fastboardUserKickedOut(_ fastboard: Fastboard, reason: String) {
        
    }
    
    func fastboard(_ fastboard: Fastboard, error: FastError) {
    }
}
