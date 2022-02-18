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
        .landscape
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
                                       userUID: "some-unique-id",
                                       useFPA: true)
        // Without fpa
//        let config = FastConfiguration(appIdentifier: RoomInfo.APPID.value,
//                                       roomUUID: RoomInfo.ROOMUUID.value,
//                                       roomToken: RoomInfo.ROOMTOKEN.value,
//                                       region: .CN,
//                                       userUID: "some-unique-id")
        config.customOverlay = custom
        let fastboard = Fastboard(configuration: config)
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
            make.top.equalToSuperview()
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
        ("userTheme", {
            let white = WhiteboardAssets(whiteboardBackgroundColor: .green, containerColor: .yellow)
            let control = ControlBarAssets(backgroundColor: .blue, borderColor: .gray, effectStyle: .init(style: .regular))
            let panel = PanelItemAssets(normalIconColor: .black, selectedIconColor: .systemRed, highlightBgColor: .cyan, subOpsIndicatorColor: .yellow, pageTextLabelColor: .orange)
            let theme = ThemeAsset(whiteboardAssets: white, controlBarAssets: control, panelItemAssets: panel)
            ThemeManager.shared.apply(theme)
        }),
        ("color", {
            DefaultOperationItem.defaultColors = [.red, .yellow, .blue]
            self.reloadFastboard(overlay: nil)
        }),
        ("phone items", {
            CompactFastboardOverlay.defaultCompactAppliance = [
                .AppliancePencil,
                .ApplianceSelector,
                .ApplianceEraser
            ]
            self.reloadFastboard(overlay: nil)
        }),
        ("pad items", {
            var items: [FastOperationItem] = []
            let shape = SubOpsItem(subOps: RegularFastboardOverlay.shapeItems)
            items.append(shape)
            items.append(DefaultOperationItem.selectableApplianceItem(.AppliancePencil, shape: nil))
            items.append(DefaultOperationItem.clean())
            let panel = FastPanel(items: items)
            RegularFastboardOverlay.customOptionPanel = {
                return panel
            }
            self.reloadFastboard(overlay: nil)
        }),
        ("direction", {
            if FastboardView.appearance().operationBarDirection == .left {
                FastboardView.appearance().operationBarDirection = .right
                self.stack.snp.remakeConstraints { make in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview().inset(88)
                    make.width.equalTo(120)
                }
            } else {
                FastboardView.appearance().operationBarDirection = .left
                self.stack.snp.remakeConstraints { make in
                    make.top.equalToSuperview()
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
            self.fastboard.updateWritable(!writable) { error in
                print("update writable \(!writable)", error?.localizedDescription ?? "success")
            }
        }),
        ("custom", {
            self.reloadFastboard(overlay: CustomFastboardOverlay())
            ControlBar.appearance().itemWidth = 66
            AppearanceManager.shared.commitUpdate()
        }),
        ("layout", {
            self.fastboard.view.overlay?.invalidAllLayout()
            if let regular = self.fastboard.view.overlay as? RegularFastboardOverlay {
                regular.operationPanel.view?.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.centerY.equalToSuperview()
                }
                
                regular.deleteSelectionPanel.view?.snp.makeConstraints({ make in
                    make.bottom.equalTo(regular.operationPanel.view!.snp.top).offset(-8)
                    make.left.equalToSuperview()
                })
                
                regular.undoRedoPanel.view?.snp.makeConstraints({ make in
                    make.left.bottom.equalTo(self.fastboard.view.whiteboardView)
                })
                
                regular.scenePanel.view?.snp.makeConstraints({ make in
                    make.bottom.equalTo(self.fastboard.view.whiteboardView)
                    make.centerX.equalToSuperview()
                })
            }
            
            if let compact = self.fastboard.view.overlay as? CompactFastboardOverlay {
                compact.operationPanel.view?.snp.makeConstraints({ make in
                    make.left.equalTo(self.fastboard.view.whiteboardView)
                    make.centerY.equalToSuperview()
                })
                
                compact.colorAndStrokePanel.view?.snp.makeConstraints({ make in
                    make.left.equalTo(self.fastboard.view.whiteboardView)
                    make.bottom.equalTo(compact.operationPanel.view!.snp.top).offset(-8)
                })
                
                compact.deleteSelectionPanel.view?.snp.makeConstraints { $0.edges.equalTo(compact.colorAndStrokePanel.view!) }
                
                compact.undoRedoPanel.view?.snp.makeConstraints({ make in
                    make.left.bottom.equalTo(self.fastboard.view.whiteboardView)
                })
                
                compact.scenePanel.view?.snp.makeConstraints({ make in
                    make.bottom.centerX.equalTo(self.fastboard.view.whiteboardView)
                })
            }
        }),
        ("pencil", {
            FastboardManager.followSystemPencilBehavior = !FastboardManager.followSystemPencilBehavior
            if let btn = self.stack.arrangedSubviews[self.stack.arrangedSubviews.count - 2] as? UIButton {
                btn.setTitle("P \(FastboardManager.followSystemPencilBehavior)", for: .normal)
            }
        }),
        ("reload", {
            UIApplication.shared.keyWindow?.rootViewController = ViewController()
        }),
    ]
}

extension ViewController: FastboardDelegate {
    func fastboardPhaseDidUpdate(_ fastboard: Fastboard, phase: FastRoomPhase) {
        print(#function, phase)
    }
    
    func fastboardUserKickedOut(_ fastboard: Fastboard, reason: String) {
        print(#function, reason)
    }
    
    func fastboard(_ fastboard: Fastboard, error: FastError) {
        print(#function, error.localizedDescription)
    }
}
