[中文](Advance-zh.md)

- [Confirm whiteboard ratio](#confirm-whiteboard-ratio)
- [Inserting multimedia content](#inserting-multimedia-content)
- [Custom App Plugin](#custom-app-plugin)
- [Interface customization](#interface-customization)
  - [Toggle theme](#toggle-theme)
  - [Modify brush color collection](#modify-brush-color-collection)
  - [Toggle the default layout overlay](#toggle-the-default-layout-overlay)
  - [Adjust global appearance](#adjust-global-appearance)
  - [Overlay show hide](#overlay-show-hide)
  - [Customized overlay](#customized-overlay)
  - [Follow ApplePencil preferred behavior](#follow-applepencil-preferred-behavior)
- [Using YYKit](#using-yykit)

## Confirm whiteboard ratio

[How to set the whiteboard scale correctly](ratio.md)

## Inserting multimedia content

A variety of file types can be inserted in the Fastboard. The methods of insertion can be found in `FastRoom`
- Inserting music or video
   
  `func insertMedia(_ src: URL, title: String, completionHandler: ((String)->Void)? = nil)`
- Inserting an image

  `func insertImg(_ src: URL, imageSize: CGSize)`
- Insert dynamic ppt

  `func insertPptx(_ pages: [WhitePptPage],
                           title: String,
                           completionHandler: ((String)->Void)? = nil)`
- Insert static files (including pdf, ppt, doc)

  `func insertStaticDocument(_ pages: [WhitePptPage],
                                     title: String,
                                     completionHandler: ((String)->Void)? = nil)`

## Custom App Plugin

The Custom App plugin extends the whiteboard functionality, and users write js code to implement their own whiteboard plugin.

To operate the Custom App plugin you need to use `WhiteSDK` and `WhiteRoom` objects, both of which can be found in `FastRoom`.

The corresponding property names are `whiteSDK` and `room`.

Custom App plugin details can be found in [Whiteboard-README-CustomApp](https://github.com/netless-io/Whiteboard-iOS/blob/master/README.md#custom-app-plugin)

## Interface customization
All of the following are demonstrated in code in the sample project
### Toggle theme
- Switching preset themes
    - Light `FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultLightTheme)`
    - Dark `FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultDarkTheme)`
    - Auto `FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultAutoTheme)`
- Switching custom themes
    ```Swift
    let white = FastRoomWhiteboardAssets(whiteboardBackgroundColor: .green, containerColor: .yellow)

    let control = FastRoomControlBarAssets(backgroundColor: .blue, borderColor: .gray, effectStyle: .init(style: .regular))

    let panel = FastRoomPanelItemAssets(normalIconColor: .black, selectedIconColor: .systemRed, highlightBgColor: .cyan, subOpsIndicatorColor: .yellow, pageTextLabelColor: .orange)

    let theme = FastRoomThemeAsset(whiteboardAssets: white, controlBarAssets: control, panelItemAssets: panel)

    FastRoomThemeManager.shared.apply(theme)
    ```

### Modify brush color collection
- Modify brush color collection 
  ```Swift
  FastRoomDefaultOperationItem.defaultColors = [.red, .yellow, .blue]
  ```

### Toggle the default layout overlay
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
### Adjust global appearance
- Adjust global appearance
  ```swift
  // Toolbar direction left
  FastRoomView.appearance().operationBarDirection == .left
  // Toolbar direction right
  FastRoomView.appearance().operationBarDirection == .right
  // Toolbar width
  FastRoomControlBar.appearance().itemWidth = 64
  // Toolbar Icons replace
  FastRoomThemeManager.shared.updateIcons(using: **Some Bundle**)
  ```
### Overlay show hide
- Overlay show hide
  ```swift
  // Hide all
  fastRoom.setAllPanel(hide: **isHide**)
  // Specific Hide 
  fastRoom.setPanelItemHide(item: **key**, hide: **isHide**)
  ```
### Customized overlay
- Use your own overlay (not recommended)
  ```swift
  let config = FastRoomConfiguration(appIdentifier: *,
                               roomUUID: *,
                               mToken: *,
                               region: *,
                               userUID: *)
  // Implement a FastOverlay of your own
  let customOverlay = CustomOverlay()
  // Add to FastConfiguration
  config.customOverlay = customOverlay
  // Generate Fastboard
  ```
- Remake overlay Constraints
  ```swift
  // invalid all overlay layout
  public func invalidAllLayout()
  ```

### Follow ApplePencil preferred behavior
- Choose whether followSystemPencilBehavior
```swift
  Fastboard.followSystemPencilBehavior
```

## Using YYKit
This SDK has a dependency on YYModel by default, if you need to change the dependency to YYKit, you can use the following command:

``` ruby
pod 'Fastboard/core-YYKit'
```

If you are using fpa:

``` ruby
pod 'Fastboard/fpa-YYKit'
```