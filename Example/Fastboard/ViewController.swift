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
import SnapKit

extension WhiteApplianceNameKey: CaseIterable {
    public static var allCases: [WhiteApplianceNameKey] {
        [.ApplianceClicker,
         .AppliancePencil,
         .ApplianceSelector,
         .ApplianceText,
         .ApplianceEllipse,
         .ApplianceRectangle,
         .ApplianceEraser,
         .ApplianceStraight,
         .ApplianceArrow,
         .ApplianceHand,
         .ApplianceLaserPointer
        ]
    }
}

extension WhiteApplianceShapeTypeKey: CaseIterable {
    public static var allCases: [WhiteApplianceShapeTypeKey] {
        [
            .ApplianceShapeTypeTriangle,
            .ApplianceShapeTypeRhombus,
            .ApplianceShapeTypePentagram,
            .ApplianceShapeTypeSpeechBalloon
        ]
    }
}

class ViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscapeRight
    }
    
    var fastboard: Fastboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFastboard()
        setupTools()
    }
    
    func setupFastboard(custom: FastboardOverlay? = nil) {
        let config = FastConfiguration(appIdentifier: RoomInfo.APPID.value,
                                       roomUUID: RoomInfo.ROOMUUID.value,
                                       roomToken: RoomInfo.ROOMTOKEN.value,
                                       region: .CN,
                                       userUID: "some-unique-id")
        config.customOverlay = custom
        let fastboard = FastboardManager.createFastboardWithConfiguration(config)
        fastboard.delegate = self
        let fastboardView = fastboard.view
        view.autoresizesSubviews = true
        view.addSubview(fastboardView)
        fastboardView.frame = view.bounds
        fastboardView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fastboard.joinRoom()
        self.fastboard = fastboard
    }
    
    func setupTools() {
        view.addSubview(stack)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(88)
            make.width.equalTo(120)
        }
    }
    
    func reloadFastboard(overlay: FastboardOverlay? = nil) {
        fastboard.view.removeFromSuperview()
        setupFastboard(custom: overlay)
        view.bringSubview(toFront: stack)
    }
    
    func buttons() -> [UIButton] {
        exampleItems.enumerated().map { index, element in
            let btn = button(title: element.0, index: index)
            btn.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
            return btn
        }
    }
    lazy var stack = UIStackView(arrangedSubviews: buttons())
    
    @objc func onClick(sender: UIButton) {
        exampleItems[sender.tag].1()
    }
    
    var isHide = false {
        didSet {
            fastboard.setAllPanel(hide: isHide)
        }
    }
    
    var currentTheme: ExampleTheme = .auto {
        didSet {
            themeChangeBtn.setTitle("T / \(currentTheme)", for: .normal)
            switch currentTheme {
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
    
    var themeChangeBtn: UIButton {
        stack.arrangedSubviews[0] as! UIButton
    }
    
    typealias ExampleItem = ((String, (()->Void)))
    lazy var exampleItems: [ExampleItem] = [
        ("theme", {
            let all = ExampleTheme.allCases
            let index = all.firstIndex(of: self.currentTheme)!
            if index == all.count - 1 {
                self.currentTheme = all.first!
            } else {
                let targeCurrentTheme = all[index + 1]
                if targeCurrentTheme == .auto {
                    if #available(iOS 13, *) {
                        self.currentTheme = targeCurrentTheme
                    } else {
                        self.currentTheme = all.first!
                    }
                } else {
                    self.currentTheme = targeCurrentTheme
                }
            }
        }),
        ("direction", {
            if FastboardView.appearance().operationBarDirection == .left {
                FastboardView.appearance().operationBarDirection = .right
                self.stack.snp.remakeConstraints { make in
                    make.top.equalToSuperview().inset(10)
                    make.left.equalToSuperview().inset(88)
                    make.width.equalTo(120)
                }
            } else {
                FastboardView.appearance().operationBarDirection = .left
                self.stack.snp.remakeConstraints { make in
                    make.top.equalToSuperview().inset(10)
                    make.right.equalToSuperview().inset(88)
                    make.width.equalTo(120)
                }
            }
            AppearanceManager.shared.commitUpdate()
        }),
        ("barSize", {
            if ControlBar.appearance().itemWidth == 48 {
                ControlBar.appearance().itemWidth = 40
            } else {
                ControlBar.appearance().itemWidth = 48
            }
            AppearanceManager.shared.commitUpdate()
        }),
        ("icons", {
            ThemeManager.shared.updateIcons(using: Bundle.main)
            self.reloadFastboard()
            self.view.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.view.isUserInteractionEnabled = true
            }
        }),
        ("hideAll", { self.isHide = !self.isHide}),
        ("hideItem", {
            let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            var values: [DefaultOperationIdentifier] = []
            values.append(contentsOf: WhiteApplianceNameKey.allCases.map { .applice(key: $0, shape: nil)})
            values.append(contentsOf: WhiteApplianceShapeTypeKey.allCases.map { .applice(key: .ApplianceShape, shape: $0) })
            let others: [DefaultOperationIdentifier] = [
                .operationType(.clean)!,
                .operationType(.previousPage)!,
                .operationType(.newPage)!,
                .operationType(.nextPage)!,
                .operationType(.redo)!,
                .operationType(.undo)!
            ]
            values.append(contentsOf: others)
            for key in values {
                alert.addAction(.init(title: key.identifier,
                                      style: .default, handler: { _ in
                    self.fastboard.setPanelItemHide(item: key, hide: true)
                }))
            }
            alert.addAction(.init(title: "cancel", style: .cancel, handler: nil))
            alert.popoverPresentationController?.sourceView = self.stack
            self.present(alert, animated: true, completion: nil)
        }),
        ("writable", {
            guard let room = self.fastboard.room else { return }
            let writable = room.isWritable
            room.setWritable(!writable) { new, error in
                print("update writable \(!writable)", error?.localizedDescription ?? "success")
            }
        }),
        ("custom", {
            self.reloadFastboard(overlay: CustomFastboardOverlay())
            ControlBar.appearance().itemWidth = 66
            AppearanceManager.shared.commitUpdate()
        }),
        ("reload", {
            UIApplication.shared.keyWindow?.rootViewController = ViewController()
        }),
    ]
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
