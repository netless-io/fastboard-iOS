# ChangeLog
本项目的所有值得注意的更改都将记录在此文件中。

# Fastboard-iOS 版本记录
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