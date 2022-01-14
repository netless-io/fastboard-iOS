# Fastboard
Quickly create a whiteboard interface for iOS and support control interface customization.
<p><a href="./README.md">中文</a></p>

## Quick Start

Clone the repository and go to the Example directory in the terminal and execute `pod install`.

Find the FastboardConfig.xcconfig file and fill in the APPID and ROMUUID and ROOMTOKEN.

Open Xcode and go to workspace, select your team, and set your bundle identifier and credentials.

Select an simulator or a real machine and press cmd+R to run the sample project.

## Requirement
Running device: iOS 10 +

Development environment: Xcode 12+

## Code Example
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
## Integration
### CocoaPods
pod ‘Fastboard’
