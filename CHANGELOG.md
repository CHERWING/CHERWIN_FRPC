# 更新日志 (Changelog)

## v1.2.2
🔧 连接稳定性全面修复（核心更新）
彻底解决 frpc 连接异常后无法自动恢复的问题，从 frpc 自身行为和外部监控双重保障。

**loginFailExit 强制关闭**
刷写后首次启动时，自动在 frpc.toml 头部注入 `loginFailExit = false`，frpc 不会再因一次连接失败就自行退出，而是保持进程持续重试。

**看门狗即时重启**
重写 watchdog_connection 逻辑：每 20 秒检测一次日志，只要最近 3 条日志中有错误且无成功记录，立即执行 stop → start 重启 frpc（不再依赖计数器累计）。

**端口释放等待**
stop_frpc 及所有重启路径（WebUI 启停、保存配置、看门狗、restart.sh）在 kill 后等待 7400 端口确认释放，彻底杜绝 `bind: address already in use`。

🧹 独立启停脚本
新增 start.sh / stop.sh / restart.sh，可在 MT 管理器中直接点击执行，方便不进入 WebUI 时手动控制。

🐛 Bug 修复
修复 代理通道状态显示：服务端连接异常时所有通道统一显示「离线」，不再依赖旧的 success 日志
修复 v1.2.0 配置备份恢复时 settings.conf 未纳入持久化的问题（新增 `/data/local/tmp/.frpc_settings_backup`，安装脚本和调度器双层兜底）

⏰ 定时运行调度器
可设置每天自动运行的时间段（如 08:00–22:00），时段外自动停止 frpc 并进入长睡眠。支持自定义检查间隔和时段外最长睡眠时长。

🌐 网络守卫
开启后 frpc 运行时检测到网络不通（ping 8.8.8.8 / 114.114.114.114 均超时），自动停止 frpc；网络恢复后自动重新启动。

🔋 低电量保护
开启后电池电量低于可自定义阈值（默认 20%）且未在充电时，自动停止 frpc 以节省电量。

⚙️ WebUI 模块设置页
新增「模块设置」标签页，支持在线开关和配置定时运行、网络守卫、故障重启、低电量保护及阈值，无需手动编辑配置文件。
WebUI 启停按钮根据运行状态自动切换显示（运行中仅显示停止，停止时仅显示启动）。

📄 更新 README / CHANGELOG 文档

## v1.2.1
🛡️ 卸载与配置持久化增强

**卸载脚本 uninstall.sh**
新增独立卸载脚本，卸载时自动停止 frpc 进程、清理 PID 文件、清除备份文件，避免残留。

**配置备份扩展**
配置持久化覆盖范围从 frpc.toml 扩展到 settings.conf（模块设置），保存设置时自动备份至 `/data/local/tmp/.frpc_settings_backup`，刷写模块时自动恢复。

🐛 Bug 修复
修复 配置手册折叠样式（header 和 body 不在同一 card 内导致布局错位）

📄 更新 README 文档

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
