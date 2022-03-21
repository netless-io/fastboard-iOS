- [Fastboard](#fastboard)
- [快速体验](#快速体验)
- [要求设备](#要求设备)
- [代码示例](#代码示例)
    - [Swift](#swift)
    - [OC](#oc)
- [接入方式](#接入方式)
- [房间设置](#房间设置)
  - [加入房间](#加入房间)
  - [离开房间](#离开房间)
  - [设置是否可写](#设置是否可写)
- [界面自定义](#界面自定义)
  - [切换主题](#切换主题)
  - [修改画笔颜色集合](#修改画笔颜色集合)
  - [切换默认布局工具栏](#切换默认布局工具栏)
  - [调整全局外观](#调整全局外观)
  - [工具栏显示隐藏](#工具栏显示隐藏)
  - [自定义工具栏](#自定义工具栏)
  - [跟随Pencil行为](#跟随pencil行为)

# Fastboard
<p><a href="./README-En.md">En</a></p>

快速创建带有操作面板的互动白板界面

支持快速配置操作面板外观

内置常用互动工具，根据需要自由选择

支持跟随ApplePencil系统行为

# 快速体验
克隆仓库，并且在终端中进入Example目录，执行`pod install`

找到FastboardConfig.xcconfig文件，填入APPID、ROOMUUID和ROOMTOKEN

打开Xcode进入workspace选择你的Team，设定bundle identifier和证书(模拟器不需要)

选择一个模拟器或者真机

按下cmd+R运行示例工程
# 要求设备
运行设备：iOS 10 +，开发环境：Xcode 12+

# 代码示例
### Swift
```swift
// 创建白板房间
let config = FastRoomConfiguration(appIdentifier: *,
                                   roomUUID: *,
                                   roomToken: *,
                                   region: *,
                                   userUID: *)
let fastRoom = Fastboard.createFastRoom(withFastRoomConfig: config)
fastboard.delegate = self
// 添加到视图层级
let fastRoomView = fastRoom.view
view.addSubview(fastRoomView)
fastRoomView.frame = view.bounds
// 白板加入房间
fastRoom.joinRoom()
// 持有白板
self.fastRoom = fastRoom
```
### OC
```ObjectiveC
FastRoomConfiguration* config = [[FastRoomConfiguration alloc] initWithAppIdentifier:* 
                                                                            roomUUID:*
                                                                           roomToken:*
                                                                              region:*
                                                                             userUID:*];
// 创建、持有白板
_fastRoom = [Fastboard createFastRoomWithFastRoomConfig:config];
FastboardView *fastRoomView = _fastRoom.view;
_fastRoom.delegate = self;
// 加入房间
[_fastRoom joinRoom];
//加入视图层级
[self.view addSubview:fastRoomView];
fastRoomView.frame = self.view.bounds;
```

# 接入方式
- CocoaPods
  ```ruby
  pod ‘Fastboard’
  ```

# 房间设置
## 加入房间
```swift
public func joinRoom(completionHandler: ((Result<WhiteRoom, FastError>)->Void)? = nil)
```
## 离开房间
```swift
public func disconnectRoom()
```
## 设置是否可写
  ```swift
  public func updateWritable(_ writable: Bool, completion: ((Error?)->Void)?
  ```

# 界面自定义
以下的所有的内容在示例工程中均有代码演示
## 切换主题
- 切换预置主题
    - 白色 `FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultLightTheme)`
    - 黑色 `FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultDarkTheme)`
    - 自动 `FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultAutoTheme)`
- 切换自定义主题
    ```Swift
    let white = FastRoomWhiteboardAssets(whiteboardBackgroundColor: .green, containerColor: .yellow)

    let control = FastRoomControlBarAssets(backgroundColor: .blue, borderColor: .gray, effectStyle: .init(style: .regular))

    let panel = FastRoomPanelItemAssets(normalIconColor: .black, selectedIconColor: .systemRed, highlightBgColor: .cyan, subOpsIndicatorColor: .yellow, pageTextLabelColor: .orange)

    let theme = FastRoomThemeAsset(whiteboardAssets: white, controlBarAssets: control, panelItemAssets: panel)

    FastRoomThemeManager.shared.apply(theme)
    ```

## 修改画笔颜色集合
- 切换预置画笔颜色 
  ```Swift
  FastRoomDefaultOperationItem.defaultColors = [.red, .yellow, .blue]
  ```

## 切换默认布局工具栏
- iPhone
    ```swift
    CompactFastRoomOverlay.defaultCompactAppliance = [
                    .AppliancePencil,
                    .ApplianceSelector,
                    .ApplianceEraser]
    ```
 - iPad
     ```swift
     var items: [FastRoomOperationItem] = []
     let shape = SubOpsItem(subOps: RegularFastRoomOverlay.shapeItems)
     items.append(shape)
     items.append(FastRoomDefaultOperationItem.selectableApplianceItem(.AppliancePencil, shape: nil))
     items.append(FastRoomDefaultOperationItem.clean())

     let panel = FastRoomPanel(items: items)

     RegularFastRoomOverlay.customOptionPanel = {
       return panel
     }
     ```       
## 调整全局外观
- 调整全局外观
  ```swift
  // 工具栏方向左边
  FastRoomView.appearance().operationBarDirection == .left
  // 工具栏方向右边
  FastRoomView.appearance().operationBarDirection == .right
  // 工具栏宽度
  FastRoomControlBar.appearance().itemWidth = 64
  // Icon替换
  FastRoomThemeManager.shared.updateIcons(using: **Some Bundle**)
  ```
## 工具栏显示隐藏
- 工具栏显示隐藏
  ```swift
  // 全部隐藏 
  fastRoom.setAllPanel(hide: **isHide**)
  // 特定隐藏
  fastRoom.setPanelItemHide(item: **key**, hide: **isHide**)
  ```
## 自定义工具栏
- 使用自己的工具栏（不推荐)
  ```swift
  let config = FastRoomConfiguration(appIdentifier: *,
                               roomUUID: *,
                               mToken: *,
                               region: *,
                               userUID: *)
  // 实现自己的一个FastRoomOverlay
  let customOverlay = CustomOverlay()
  // 添加到FastConfiguration中
  config.customOverlay = customOverlay
  // 生成Fastboard
  ```
- 自定义工具栏约束
  ```swift
  // 使默认布局失效
  public func invalidAllLayout()
  ```

## 跟随Pencil行为
- 选择Pencil行为
  ```swift
  Fastboard.followSystemPencilBehavior
  ```