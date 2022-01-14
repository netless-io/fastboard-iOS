# Fastboard
快速创建iOS端的白板界面，支持控制界面自定义。
<p><a href="./README-En.md">En</a></p>

## 快速体验
克隆仓库，并且在终端中进入Example目录，执行`pod install`
找到FastboardConfig.xcconfig文件，填入APPID、ROOMUUID和ROOMTOKEN。
打开Xcode进入workspace选择你的Team，设定bundle identifier和证书(模拟器不需要)
选择一个模拟器或者真机，按下cmd+R运行示例工程。

## 要求设备
运行设备：iOS 10 +，开发环境：Xcode 12+

## 代码示例
### Swift
```swift
let config = FastConfiguration(appIdentifier: *,
                               roomUUID: *,
                               mToken: *,
                               region: *,
                               userUID: *)
// 创建白板
let fastboard = Fastboard(configuration: config)
fastboard.delegate = self
// 添加到视图层级
let fastboardView = fastboard.view
view.addSubview(fastboardView)
fastboardView.frame = view.bounds
// 白板加入房间
fastboard.joinRoom()
// 持有白板
self.fastboard = fastboard
```
### OC
```ObjectiveC
FastConfiguration* config = [[FastConfiguration alloc] initWithAppIdentifier:*]
                                                                    roomUUID:*
                                                                    roomToken:*
                                                                    region: *
                                                                    userUID:*];
// 创建、持有白板
_fastboard = [[Fastboard alloc] initWithConfiguration:config];
FastboardView *fastView = _fastboard.view;
_fastboard.delegate = self;
// 加入房间
[_fastboard joinRoom];
//加入视图层级
[self.view addSubview:fastView];
fastView.frame = self.view.bounds;
```

## 接入方式
### CocoaPods
pod ‘Fastboard’

## 界面自定义
以下的所有的内容在示例工程中均有代码演示

1. 切换主题
    - 切换预置主题
        - 白色 Themanager.shared.apply(DefaultTheme.defaultLightTheme)
        - 黑色 Themanager.shared.apply(DefaultTheme.defaultDarkTheme)
        - 跟随系统(iOS13以上) Themanager.shared.apply(DefaultTheme.defaultAutoTheme)

    - 切换自定义主题
    ```swift
    let white = WhiteboardAssets(whiteboardBackgroundColor: .green, containerColor: .yellow)
    let control = ControlBarAssets(backgroundColor: .blue, borderColor: .gray, effectStyle: .init(style: .regular))
    let panel = PanelItemAssets(normalIconColor: .black, selectedIconColor: .systemRed, highlightBgColor: .cyan, subOpsIndicatorColor: .yellow, pageTextLabelColor: .orange)
    let theme = ThemeAsset(whiteboardAssets: white, controlBarAssets: control, panelItemAssets: panel)
    ThemeManager.shared.apply(theme)
    ```
2. 切换预置画笔颜色
    - DefaultOperationItem.defaultColors = [.red, .yellow, .blue]
3. 切换默认布局工具栏
    - iPhone
    ```swift
    CompactFastboardOverlay.defaultCompactAppliance = [
                .AppliancePencil,
                .ApplianceSelector,
                .ApplianceEraser]
     ```
     - iPad
     ```swift
     var items: [FastOperationItem] = []
     let shape = SubOpsItem(subOps: RegularFastboardOverlay.shapeItems)
     items.append(shape)
     items.append(DefaultOperationItem.selectableApplianceItem(.AppliancePencil, shape: nil))
     items.append(DefaultOperationItem.clean())
     let panel = FastPanel(items: items)
     RegularFastboardOverlay.customOptionPanel = {
       return panel
     }
     ```       
4. 调整全局外观
    - 工具栏方向左边 FastboardView.appearance().operationBarDirection == .left
    - 工具栏方向右边 FastboardView.appearance().operationBarDirection == .right
    - 工具栏宽度 ControlBar.appearance().itemWidth = 64
    - Icon替换 ThemeManager.shared.updateIcons(using: **Some Bundle**)
5. 主动隐藏工具栏
    - 全部隐藏 fastboard.setAllPanel(hide: **isHide**)
    - 特定隐藏 fastboard.setPanelItemHide(item: **key**, hide: **isHide**)
6. 设置是否可写 fastboard.updateWritable
7. 设置完全自定义工具栏 FastConfiguration. customOverlay
8. 设置自定义工具栏布局 fastboard.view.overlay?.invalidAllLayout()