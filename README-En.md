- [Fastboard](#fastboard)
- [Quick Start](#quick-start)
- [Requirement](#requirement)
- [Code Example](#code-example)
    - [Swift](#swift)
    - [OC](#oc)
- [Integration](#integration)
- [Room Setting](#room-setting)
  - [Join Room](#join-room)
  - [Disconnect Room](#disconnect-room)
  - [Update Room Writable](#update-room-writable)
- [Interface customization](#interface-customization)
  - [Toggle theme](#toggle-theme)
  - [Modify brush color collection](#modify-brush-color-collection)
  - [Toggle the default layout overlay](#toggle-the-default-layout-overlay)
  - [Adjust global appearance](#adjust-global-appearance)
  - [Overlay show hide](#overlay-show-hide)
  - [Customized overlay](#customized-overlay)
  - [Follow ApplePencil preferred behavior](#follow-applepencil-preferred-behavior)
# Fastboard
<p><a href="./README.md">中文</a></p>

Quickly create interactive whiteboard interfaces with operator panels

Quickly configure the appearance of the operator panel

Built-in common interactive tools, choose freely as needed

Support for following ApplePencil system behavior

# Quick Start

Clone the repository and go to the Example directory in the terminal and execute `pod install`.

Find the FastboardConfig.xcconfig file and fill in the APPID and ROMUUID and ROOMTOKEN.

Open Xcode and go to workspace, select your team, and set your bundle identifier and credentials.

Select an simulator or a real machine and press cmd+R to run the sample project.
# Requirement
Running device: iOS 10 +

Development environment: Xcode 12+

# Code Example
### Swift
```swift
// Create fastboard
let config = FastRoomConfiguration(appIdentifier: *,
                                   roomUUID: *,
                                   roomToken: *,
                                   region: *,
                                   userUID: *)
let fastRoom = Fastboard.createFastRoom(withFastRoomConfig: config)
fastboard.delegate = self
// Add to view hierarchy
let fastRoomView = fastRoom.view
view.addSubview(fastRoomView)
fastRoomView.frame = view.bounds
// Join room
fastRoom.joinRoom()
// Retain the object
self.fastRoom = fastRoom
```

### OC
```ObjectiveC
// Create and hold fastboard
FastRoomConfiguration* config = [[FastRoomConfiguration alloc] initWithAppIdentifier:* 
                                                                            roomUUID:*
                                                                           roomToken:*
                                                                              region:*
                                                                             userUID:*];
_fastRoom = [Fastboard createFastRoomWithFastRoomConfig:config];
FastboardView *fastRoomView = _fastRoom.view;
_fastRoom.delegate = self;
// join room
[_fastRoom joinRoom];
// Add to view hierarchy
[self.view addSubview:fastRoomView];
fastRoomView.frame = self.view.bounds;
```
# Integration
- CocoaPods
  ```ruby
  pod ‘Fastboard’
  ```

# Room Setting
## Join Room
```swift
public func joinRoom(completionHandler: ((Result<WhiteRoom, FastError>)->Void)? = nil)
```
## Disconnect Room
```swift
public func disconnectRoom()
```
## Update Room Writable
  ```swift
  public func updateWritable(_ writable: Bool, completion: ((Error?)->Void)?
  ```

# Interface customization
All of the following are demonstrated in code in the sample project
## Toggle theme
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

## Modify brush color collection
- Modify brush color collection 
  ```Swift
  FastRoomDefaultOperationItem.defaultColors = [.red, .yellow, .blue]
  ```

## Toggle the default layout overlay
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
## Adjust global appearance
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
## Overlay show hide
- Overlay show hide
  ```swift
  // Hide all
  fastRoom.setAllPanel(hide: **isHide**)
  // Specific Hide 
  fastRoom.setPanelItemHide(item: **key**, hide: **isHide**)
  ```
## Customized overlay
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

## Follow ApplePencil preferred behavior
- Choose whether followSystemPencilBehavior
```swift
  Fastboard.followSystemPencilBehavior
```