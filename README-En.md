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
let config = FastConfiguration(appIdentifier: *,
                               roomUUID: *,
                               mToken: *,
                               region: *,
                               userUID: *)                              
let fastboard = Fastboard(configuration: config)
fastboard.delegate = self
// Add to view hierarchy
let fastboardView = fastboard.view
view.addSubview(fastboardView)
fastboardView.frame = view.bounds
// Join room
fastboard.joinRoom()
// Hold the object
self.fastboard = fastboard
```

### OC
```ObjectiveC
// Create and hold fastboard
FastConfiguration* config = [[FastConfiguration alloc] initWithAppIdentifier:*]
                                                                    roomUUID:*
                                                                    roomToken:*
                                                                    region: *
                                                                    userUID:*];
_fastboard = [[Fastboard alloc] initWithConfiguration:config];
FastboardView *fastView = _fastboard.view;
_fastboard.delegate = self;
// join room
[_fastboard joinRoom];
// Add to view hierarchy
[self.view addSubview:fastView];
fastView.frame = self.view.bounds;
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
    - Light `Themanager.shared.apply(DefaultTheme.defaultLightTheme)`
    - Dark `Themanager.shared.apply(DefaultTheme.defaultDarkTheme)`
    - Auto `Themanager.shared.apply(DefaultTheme.defaultAutoTheme)`
- Switching custom themes
    ```Swift
    let white = WhiteboardAssets(whiteboardBackgroundColor: .green, containerColor: .yellow)

    let control = ControlBarAssets(backgroundColor: .blue, borderColor: .gray, effectStyle: .init(style: .regular))

    let panel = PanelItemAssets(normalIconColor: .black, selectedIconColor: .systemRed, highlightBgColor: .cyan, subOpsIndicatorColor: .yellow, pageTextLabelColor: .orange)

    let theme = ThemeAsset(whiteboardAssets: white, controlBarAssets: control, panelItemAssets: panel)

    ThemeManager.shared.apply(theme)
    ```

## Modify brush color collection
- Modify brush color collection 
  ```Swift
  DefaultOperationItem.defaultColors = [.red, .yellow, .blue]
  ```

## Toggle the default layout overlay
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
## Adjust global appearance
- Adjust global appearance
  ```swift
  // Toolbar direction left
  FastboardView.appearance().operationBarDirection == .left
  // Toolbar direction right
  FastboardView.appearance().operationBarDirection == .right
  // Toolbar width
  ControlBar.appearance().itemWidth = 64
  // Toolbar Icons replace
  ThemeManager.shared.updateIcons(using: **Some Bundle**)
  ```
## Overlay show hide
- Overlay show hide
  ```swift
  // Hide all
  fastboard.setAllPanel(hide: **isHide**)
  // Specific Hide 
  fastboard.setPanelItemHide(item: **key**, hide: **isHide**)
  ```
## Customized overlay
- Use your own overlay (not recommended)
  ```swift
  let config = FastConfiguration(appIdentifier: *,
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
  FastboardManager.followSystemPencilBehavior
```