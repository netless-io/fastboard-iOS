# Fastboard
快速创建iOS端的白板界面，支持控制界面自定义。
<p><a href="./README-En.md">En</a></p>

## 快速体验
克隆仓库，并且在终端中进入Example目录，执行`pod install`
找到FastboardConfig.xcconfig文件，填入APPID和ROOMUUID和ROOMTOKEN。
打开Xcode进入workspace选择你Team，并且设定你的bundle identifier和证书
选择一个模拟器或者真机，按下cmd+R运行示例工程。

## 要求设备
运行设备：iOS 10 +，开发环境：Xcode 12+

## 代码示例
### Swift
```swift
// 创建白板
let fastboard = FastBoardSDK.createFastboardWith(appId: “***”,
                                                 roomUUID: “***”,
                                                 roomToken: “***”,
                                                 userUID: “***”)
        
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
// 创建、持有白板
_fastboard = [FastBoardSDK createFastboardWithAppId:@“*”
                                  roomUUID: @“*”
                                 roomToken: @“*”
                                   userUID:@"some-unique"
                       customFastBoardView:nil];
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
