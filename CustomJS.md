# Custom JavaScript Interaction

Fastboard is built on top of Whiteboard SDK, which uses [DSBridge](https://github.com/netless-io/DSBridge-IOS) for bidirectional communication between Native and JavaScript. By accessing `WhiteBoardView`, you can implement custom JavaScript interaction features.

## Accessing WhiteBoardView

`FastRoom` provides direct access to `WhiteBoardView`:

```swift
let fastRoom = Fastboard.createFastRoom(withFastRoomConfig: config)
let whiteboardView = fastRoom.view.whiteboardView
```

`WhiteBoardView` inherits from `DWKWebView`, providing complete JavaScript bridging capabilities.

## Calling JavaScript Methods

### 1. Call JS Method (without callback)

```swift
fastRoom.view.whiteboardView.callHandler("methodName", arguments: ["arg1", "arg2"])
```

### 2. Call JS Method (with callback)

```swift
fastRoom.view.whiteboardView.callHandler("methodName",
                                         arguments: ["arg1", "arg2"]) { result in
    if let data = result {
        print("JS returned: \(data)")
    }
}
```

## Registering Native Objects for JavaScript

### 1. Create Native Interface Class

```swift
@objc class CustomJSBridge: NSObject {
    @objc func showMessage(_ message: String) -> String {
        print("Message from JS: \(message)")
        // Show alert or handle message
        return ""
    }

    @objc func getValue(_ args: Any, handler: JSCallback) {
        handler("success", true)
    }
}
```

### 2. Register to Whiteboard

```swift
let customBridge = CustomJSBridge()
fastRoom.view.whiteboardView.addJavascriptObject(customBridge, namespace: "custom")
```

### 3. Call from JavaScript

After registration, you can call from JavaScript like this:

```javascript
// Synchronous call
bridge.call("custom.showMessage", "Whiteboard Bridge Room registered");

// Asynchronous call
const result = await bridge.asyncCall("custom.getValue", [1, 2]);
```

## Important Notes

1. **Thread Safety**: All JavaScript-related calls should be executed on the main thread
2. **Memory Management**: Be careful to avoid retain cycles, especially use `weak self` in closures
3. **Type Conversion**: Data between JavaScript and Native is automatically converted. Supported types include:
   - Number (NSNumber)
   - String (NSString)
   - Boolean (NSNumber)
   - Array (NSArray)
   - Object (NSDictionary)
   - null/undefined (nil)
4. **Method Naming**: Native method names are automatically converted to camelCase for JavaScript
5. **Return Values**: Asynchronous methods need to use `JSCallback` to return results

## Related Resources

- [DSBridge Documentation](https://github.com/netless-io/DSBridge-IOS)
- [Whiteboard SDK Documentation](https://github.com/netless-io/Whiteboard-iOS)
