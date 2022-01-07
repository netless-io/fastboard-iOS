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
        setupFastboard()
        setupTools()
    }
    
    func reloadFastboard() {
        board.view.removeFromSuperview()
        setupFastboard()
        view.bringSubview(toFront: stack)
    }
    
    func setupFastboard() {
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
        f.joinRoom()
        self.board = f
    }
    
    func setupTools() {
        view.addSubview(stack)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.frame = .init(origin: .init(x: view.bounds.width - 88, y: 10),
                            size: .init(width: 88, height: CGFloat(stack.arrangedSubviews.count * 66)))
    }
    
    @objc func onClickUpdateDirection() {
        if FastboardView.appearance().operationBarDirection == .left {
            FastboardView.appearance().operationBarDirection = .right
        } else {
            FastboardView.appearance().operationBarDirection = .left
        }
        AppearanceManager.shared.commitUpdate()
    }
    
    @objc func onClickUpdateControlBarSize() {
        if ControlBar.appearance().itemWidth == 48 {
            ControlBar.appearance().itemWidth = 40
        } else {
            ControlBar.appearance().itemWidth = 48
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
    
    @objc func onClickCustomBundle(_ sender: UIButton) {
        ThemeManager.shared.updateIcons(using: Bundle.main)
        reloadFastboard()
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            sender.isEnabled = true
        }
    }
    
    var isHide = false {
        didSet {
            board.setAllPanel(hide: isHide)
        }
    }
    
    @objc func onClickHideAll() {
        isHide = !isHide
    }
    
    @objc func onClickHideItem(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let keys: [DefaultOperationKey] = [
            .appliance(.pencil),
            .appliance(.rectangle),
            .shape(.pentagram),
            .clean,
            .previousPage,
            .newPage,
            .nextPage,
            .redo,
            .undo
        ]
        for key in keys {
            alert.addAction(.init(title: key.identifier,
                                  style: .default, handler: { _ in
                self.board.setPanelItemHide(item: key, hide: true)
            }))
        }
        alert.addAction(.init(title: "cancel", style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = sender
        present(alert, animated: true, completion: nil)
    }
    
    lazy var stack = UIStackView(arrangedSubviews: [themeChangeBtn,
                                                    operationDirectionChange,
                                                    updateControlBarSize,
                                                    customBundle,
                                                    hideAllButton,
                                                    hideItemButton])
    
    
    func randomColor() -> UIColor {
        let indicates: [UIColor] = [
            .red,
            .black,
            .orange,
            .blue,
            .green,
            .systemPink,
            .brown,
            .gray,
            .purple
        ]
        let i = Int.random(in: 0..<9)
        return indicates[i]
    }
    
    lazy var themeChangeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor =  randomColor()
        btn.setTitle("T / auto", for: .normal)
        btn.addTarget(self, action: #selector(onClickUpdateTheme), for: .touchUpInside)
        return btn
    }()
    
    lazy var operationDirectionChange: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = randomColor()
        btn.setTitle("OpDirect", for: .normal)
        btn.addTarget(self, action: #selector(onClickUpdateDirection), for: .touchUpInside)
        return btn
    }()
    
    lazy var updateControlBarSize: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = randomColor()
        btn.setTitle("cBarSize", for: .normal)
        btn.addTarget(self, action: #selector(onClickUpdateControlBarSize), for: .touchUpInside)
        return btn
    }()
    
    lazy var customBundle: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = randomColor()
        btn.setTitle("icons", for: .normal)
        btn.addTarget(self, action: #selector(onClickCustomBundle), for: .touchUpInside)
        return btn
    }()
    
    lazy var hideAllButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = randomColor()
        btn.setTitle("hide all", for: .normal)
        btn.addTarget(self, action: #selector(onClickHideAll), for: .touchUpInside)
        return btn
    }()
    
    lazy var hideItemButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = randomColor()
        btn.setTitle("hide Item", for: .normal)
        btn.addTarget(self, action: #selector(onClickHideItem), for: .touchUpInside)
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
