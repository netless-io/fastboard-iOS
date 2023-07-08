
- [确认白板比例](#确认白板比例)
- [插入多媒体内容](#插入多媒体内容)
- [自定义App插件](#自定义app插件)
- [界面自定义](#界面自定义)
  - [切换主题](#切换主题)
  - [修改画笔颜色集合](#修改画笔颜色集合)
  - [切换默认布局工具栏](#切换默认布局工具栏)
  - [调整全局外观](#调整全局外观)
  - [工具栏显示隐藏](#工具栏显示隐藏)
  - [自定义工具栏](#自定义工具栏)
  - [跟随Pencil行为](#跟随pencil行为)
- [使用YYKit](#使用yykit)

## 确认白板比例

[如何正确设置白板比例](ratio-zh.md)

## 插入多媒体内容

在实时白板中可以插入多种文件类型。插入的方法可以`FastRoom`中找到
- 插入音乐或视频
   
  `func insertMedia(_ src: URL, title: String, completionHandler: ((String)->Void)? = nil)`
- 插入图片

  `func insertImg(_ src: URL, imageSize: CGSize)`
- 插入动态ppt

  `func insertPptx(_ pages: [WhitePptPage],
                           title: String,
                           completionHandler: ((String)->Void)? = nil)`
- 插入静态文件(包括 pdf, ppt, doc)

  `func insertStaticDocument(_ pages: [WhitePptPage],
                                     title: String,
                                     completionHandler: ((String)->Void)? = nil)`

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

## 使用YYKit
本SDK默认有依赖YYModel, 如果需要更改依赖为YYKit，可以使用如下命令:

``` ruby
pod 'Fastboard/core-YYKit'
```
