# 高级功能

[English](Advance)

## 自定义App插件

自定义App插件可以扩展白板功能，用户通过编写js代码来实现自己的白板插件。

操作自定义App插件需要用到`WhiteSDK`和`WhiteRoom`对象，这两个对象均可以在`FastRoom`中找到。

对应的属性名为`whiteSDK`和`room`

自定义App插件详情见[Whiteboard-README-CustomApp](https://github.com/netless-io/Whiteboard-iOS/blob/master/README-zh.md#自定义App插件)

## 界面自定义
以下的所有的内容在示例工程中均有代码演示
### 切换主题
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

### 修改画笔颜色集合
- 切换预置画笔颜色 
  ```Swift
  FastRoomDefaultOperationItem.defaultColors = [.red, .yellow, .blue]
  ```

### 切换默认布局工具栏
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
### 调整全局外观
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
### 工具栏显示隐藏
- 工具栏显示隐藏
  ```swift
  // 全部隐藏 
  fastRoom.setAllPanel(hide: **isHide**)
  // 特定隐藏
  fastRoom.setPanelItemHide(item: **key**, hide: **isHide**)
  ```
### 自定义工具栏
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

### 跟随Pencil行为
- 选择Pencil行为
  ```swift
  Fastboard.followSystemPencilBehavior
  ```
