# 更新日志 (Changelog)

## v1.2.0
* 🛡️ 配置保留机制：刷写更新不再丢失 frpc.toml，WebUI 保存/启动时自动备份到 /data/local/tmp/
* 🔄 开机配置恢复：service.sh 开机时自动检测备份并还原，确保配置不丢失
* 🧩 首次安装体验优化：无 frpc.toml 时自动读取并显示 frpc.toml.template，保存即生成
* 📊 内存读取三路 fallback：ps -o rss → /proc/PID/status → ps 通用，适配不同 Android 版本
* 🐛 修复 KernelSU source 执行 customize.sh 时 $MODDIR 路径错误的问题
* 🐛 修复 base64 编码传输绕过 WebView 桥中文字符乱码
* 🐛 修复 backup 恢复后文件被 KernelSU 安装器清理的问题
* 🎨 配置手册折叠样式修正

## v1.1.0
* 🎯 WebUI 全面重构：改用 `ksu.exec()` API，不再依赖 CGI + busybox httpd
* 🎨 iOS 风格全新 UI：状态/配置/日志三栏式卡片布局
* 🔵 运行状态实时动画：绿色脉冲呼吸灯表示运行中，红色表示已停止
* ⚡ 配置保存改为 base64 编码写入，解决中文乱码问题
* 📖 配置标签页内嵌完整的配置手册
* 🛠️ 移除 httpd 依赖，WebUI 需在 KernelSU 模块 WebView 内打开

## v1.0.0
* 🎉 首个正式版本发布
* 🔄 内置 FRP 核心组件升级至 v0.69.1
* 🌐 全新打造独立的 WebUI 交互式控制面板 (端口 8099)
* 📊 增加 FRP 核心进程与内存状态实时监控
* 🔌 增加主服务端连通性及独立代理通道连接状态可视化侦测
* 📝 支持 Web 端 `frpc.toml` 配置参数热重载
* 📚 内置详尽的本地配置手册，包含 Store 持久化及多域名穿透实战教程
* 🔍 深度集成 Magisk/KernelSU 生态环境
