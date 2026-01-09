# Fastboard
<p><a href="./README-zh.md">中文</a></p>

Quickly create interactive whiteboard interfaces with operator panels

Quickly configure the appearance of the operator panel

Built-in common interactive tools, choose freely as needed

Support for following ApplePencil system behavior

[Advanced Features](Advance.md)

[Custom JavaScript Interaction](CustomJS.md)

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
