# ChangeLog
## [1.0.6] - 2022-05-17
内部接口重命名
### 升级
- `Whiteboard`升级到2.16.21
## [1.0.5] - 2022-04-24
## 新增
- 支持YYKit，详情见Advance
### 升级
- `Whiteboard`升级到2.16.19
## [1.0.4] - 2022-04-21
### 新增
- 支持自定义App注册和插入，详见README
### 升级
- `Whiteboard`升级到2.16.18
### 修复
- 修复`FastRoomControlBar`的`forceHide`
## [1.0.3] - 2022-03-21
### 变更
- `Fastboard`改名为`FastRoom`
- `Fastboard`增加`createFastRoom:`方法
## [1.0.2] - 2022-03-18
### 升级
- 升级`Whiteboard-iOS`到2.16.7
### 新增
- 新增OC插入多媒体示例
### 优化
- 优化`ControlBar`forceHide行为
## [1.0.0-beta.10] - 2022-02-28
### 新增
- 多种文档的插入Api。支持ppt/pptx/doc/docx/pdf/mp4/mp4/jpg/png等常见格式
- FPA加速，打开后可以在网络情况较差的情况提升应用稳定性。需要iOS13以上
## [1.0.0-beta.5]
- 更新`Whiteboad`版本到2.15.25
### 新增
- 弱网重连时增加Loading
### 优化
- 更新拦截Pencil行为，保留系统WKWebView代理行为
- 修改翻页显示和点击错误
- ControlBar使用Frame实现，不再使用UIStackView
### 修复
- 主题功能一些错误
## [1.0.0-beta.2]
### 新增
- 使用默认Overlay既可支持ApplePencil系统行为


## [1.0.0-beta.1]
### 修复
- 修复翻页错误
- 修复颜色可以多选的错误
## [0.3.4] - 2022-01-14
### 新增
- 主动隐藏SubPanel方法, Fastboard.dismissAllSubPanels
### 优化
- 优化默认SubPanel动画
## [0.3.2] - 2022-01-13
### 新增
- 支持自定义布局
- Fastboard增加setWritable方法
- 增加overlaySetup回调，可以在这里局部修改样式
- 增加SubPanel的默认动画
### 优化
- hook变为由oc的load实现，不再手动调用
- 修复主题的一些错误
- 优化了Whiteboard主题的更改，不再需要weaktable
## [0.2.0] - 2022-01-12
### 新增
- 增加对OC的支持，包括主题/工具操作/自定义面板
- FastboardView被拆解为FastboardView + FastOverlay
- 创建Fastboard参数由方法参数列表修改为FastConfiguration对象
- FastboardSDK重命名为FastboardManager
