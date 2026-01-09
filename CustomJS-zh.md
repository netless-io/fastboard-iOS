# 自定义 JS 交互

Fastboard 基于 Whiteboard SDK 构建,而 Whiteboard SDK 使用 [DSBridge](https://github.com/netless-io/DSBridge-IOS) 实现 Native 与 JavaScript 的双向通信。通过访问 `WhiteBoardView`,你可以实现自定义的 JavaScript 交互功能。

## 访问 WhiteBoardView

`FastRoom` 提供了对 `WhiteBoardView` 的直接访问:

```swift
let fastRoom = Fastboard.createFastRoom(withFastRoomConfig: config)
let whiteboardView = fastRoom.view.whiteboardView
```

`WhiteBoardView` 继承自 `DWKWebView`,提供了完整的 JavaScript 桥接能力。

## 调用 JavaScript 方法

### 1. 调用 JS 方法(无回调)

```swift
fastRoom.view.whiteboardView.callHandler("methodName", arguments: ["arg1", "arg2"])
```

### 2. 调用 JS 方法(带回调)

```swift
fastRoom.view.whiteboardView.callHandler("methodName",
                                         arguments: ["arg1", "arg2"]) { result in
    if let data = result {
        print("JS 返回结果: \(data)")
    }
}
```

## 注册 Native 对象供 JavaScript 调用

### 1. 创建 Native 接口类

```swift
@objc class CustomJSBridge: NSObject {
    @objc func showMessage(_ message: String) -> String {
        print("来自 JS 的消息: \(message)")
        // 显示 alert 或处理消息
        return ""
    }

    @objc func getValue(_ args: Any, handler: JSCallback) {
        handler("success", true)
    }
}
```

### 2. 注册到白板

```swift
let customBridge = CustomJSBridge()
fastRoom.view.whiteboardView.addJavascriptObject(customBridge, namespace: "custom")
```

### 3. 在 JavaScript 中调用

注册后,可以在 JavaScript 中这样调用:

```javascript
// 同步调用
bridge.call("custom.showMessage", "Whiteboard Bridge Room registered");

// 异步调用
const result = await bridge.asyncCall("custom.getValue", [1, 2]);
```

## 注意事项

1. **线程安全**: 所有 JavaScript 相关的调用都应该在主线程执行
2. **内存管理**: 注意避免循环引用,特别是在闭包中使用 `weak self`
3. **类型转换**: JavaScript 和 Native 之间的数据会自动转换,支持的类型包括:
   - Number (NSNumber)
   - String (NSString)
   - Boolean (NSNumber)
   - Array (NSArray)
   - Object (NSDictionary)
   - null/undefined (nil)
4. **方法命名**: Native 方法名会自动转换为驼峰式命名供 JavaScript 调用
5. **返回值**: 异步方法需要使用 `JSCallback` 来返回结果

## 相关资源

- [DSBridge 文档](https://github.com/netless-io/DSBridge-IOS)
- [Whiteboard SDK 文档](https://github.com/netless-io/Whiteboard-iOS)
