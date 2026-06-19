<p align="center">
  <img src="https://img.shields.io/badge/FRPC-v0.69.1-blue?style=flat-square" alt="FRPC">
  <img src="https://img.shields.io/badge/module-v1.2.2-green?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/support-KernelSU%20%7C%20Magisk-orange?style=flat-square" alt="Support">
  <img src="https://img.shields.io/badge/arch-arm64-red?style=flat-square" alt="Arch">
</p>

<div align="center">
  <h1>CHERWIN FRPC</h1>
  <p>高性能 FRP 内网穿透客户端 · KernelSU / Magisk 专版</p>
  <p>
    <a href="README.md">中文</a> ·
    <a href="README_en.md">English</a>
  </p>
</div>

---

## 项目简介

CHERWIN FRPC 是一个专为 Android Root 环境（KernelSU & Magisk）打造的 FRP 内网穿透模块。内嵌最新 FRPC 核心（v0.69.1），通过 KernelSU WebView 原生 API 提供完整的管理面板，无需 busybox、无需 httpd，开箱即用。

---

## 功能特性

### 🚀 核心能力
- **全协议穿透** — TCP / UDP / HTTP / HTTPS / STCP / XTCP / SUDP
- **token 认证** — 与服务端安全通信
- **负载均衡 & 健康检查** — 多节点自动切换
- **Store 持久化** — FRP v0.52+ store 特性，防重启掉线

### 🖥️ WebUI 管理面板
- **实时状态** — 进程存活、服务端连接、代理通道在线/离线
- **连接异常看门狗** — 自动检测日志错误，即时重启 frpc
- **定时运行调度器** — 设置起止时间，时段外自动休眠省电
- **网络守卫** — 断网自动停止，网络恢复自动启动
- **低电量保护** — 可自定义阈值（默认 20%）
- **配置热重载** — 在线编辑 `frpc.toml`，保存即重启
- **内置配置手册** — 完整配置教程和代理模板参考

### 💾 配置持久化
- 配置文件自动备份到 `/data/local/tmp/`，刷写模块不丢失
- 安装脚本和开机脚本双层兜底恢复

### 📜 独立脚本
- `start.sh` / `stop.sh` / `restart.sh` — MT 管理器可直接执行
- `uninstall.sh` — 卸载时自动清理
- `action.sh` — 模块列表「▶」快捷启停

---

## 安装

### 前置条件
- Android 设备已获取 Root 权限
- 已安装 **KernelSU**（推荐）或 **Magisk**
- 仅支持 **arm64（aarch64）** 架构

### 安装步骤

```bash
# 1. 下载最新发布包
# 从 GitHub Releases 下载 CHERWIN_FRPC_magisk_module.zip

# 2. 刷入模块
# KernelSU / Magisk → 模块 → 从本地安装 → 选择 ZIP

# 3. 重启设备
```

### 首次配置

1. 打开 KernelSU → 模块列表 → 点击 CHERWIN FRPC 的 **WebUI（<>）** 按钮
2. 切换到「配置」标签页
3. 修改 `serverAddr` 和 `auth.token` 为你的服务器信息
4. 点击「保存」，frpc 自动重启生效

> ⚠️ 管理面板需在 KernelSU 模块 WebView 内打开（依赖 `ksu.exec()` API），不支持外部浏览器

---

## 使用方法

### 基础流程
1. 填写服务器地址和 token → 保存
2. 添加需要的代理通道（TCP / HTTP / HTTPS 等）
3. frpc 自动启动，在状态页查看连接

### 定时运行（省电）
- 开启「定时运行」，设置每天运行时段（如 08:00–22:00）
- 时段外 frpc 自动停止并进入长睡眠

### 故障重启（防掉线）
- 开启「故障重启」，看门狗每 20 秒检测日志
- 检测到连接错误且无成功 → 自动重启 frpc

### 网络守卫（防异常）
- 检测到网络不通 → 自动停止 frpc
- 网络恢复 → 自动重新启动

### 低电量保护（防耗电）
- 电量低于阈值（默认 20%）且未充电 → 自动停止
- 充电恢复后调度器自动拉起

---

## 配置持久化说明

| 触发时机 | 备份内容 | 备份路径 |
|---------|---------|---------|
| WebUI 保存配置 | frpc.toml | `/data/local/tmp/.frpc_config_backup` |
| WebUI 保存模块设置 | settings.conf | `/data/local/tmp/.frpc_settings_backup` |
| 开机成功连接服务端 | frpc.toml | `/data/local/tmp/.frpc_config_backup` |
| 刷写新版本 | — | 安装脚本自动从备份恢复 |

---

## 常见问题

<details>
<summary><b>Q：WebUI 打不开？</b></summary>
从 KernelSU 模块列表点击「WebUI（<>）」进入，不要用浏览器直接打开。
</details>

<details>
<summary><b>Q：状态一直显示「检测中」？</b></summary>
关闭页面重新点击 WebUI 按钮打开。
</details>

<details>
<summary><b>Q：刷写模块后配置会丢吗？</b></summary>
v1.2.0 以上不会。配置自动备份到 /data/local/tmp/，刷写时自动恢复。
</details>

<details>
<summary><b>Q：连接异常但不自动恢复？</b></summary>
检查模块设置中「故障重启」是否开启，看门狗间隔是否合理（默认 20s）。同时确认服务端地址和端口正确。
</details>

<details>
<summary><b>Q：端口冲突怎么办？</b></summary>
frpc Dashboard 默认端口 7400，可在配置中修改 webServer.port。
</details>

---

## 版本历史

### v1.2.2（当前）
- 🔧 loginFailExit 强制关闭
- 🛡️ 看门狗即时重启（有错误无成功立即重启）
- 🔌 端口释放等待，杜绝 `bind: address already in use`
- 📜 独立启停脚本（MT 管理器可直接执行）
- ⏰ 定时运行、网络守卫、低电量保护
- ⚙️ WebUI 模块设置页

### v1.2.1
- 🗑️ 卸载脚本 uninstall.sh
- 💾 配置备份扩展至 settings.conf

### v1.2.0
- 🛡️ 配置保留机制
- 🔄 开机自动恢复配置
- 🧩 首次安装模板加载
- 📊 内存读取多路 fallback

### v1.1.0
- 🎯 WebUI 全面重构（`ksu.exec()` API）
- 🎨 iOS 风格新 UI
- 📖 内嵌配置手册

### v1.0.0
- 🎉 首个正式版
- 🔄 FRPC 核心 v0.69.1

---

## 致谢

- [FRP](https://github.com/fatedier/frp) — 开源内网穿透工具
- KernelSU WebView API — 原生管理面板支持

---

<div align="center">
  <p>Built with ❤️ by <a href="https://github.com/CHERWING">CHERWIN</a></p>
  <p>
    <a href="https://github.com/CHERWING/CHERWIN_FRPC">
      <img src="https://img.shields.io/badge/GitHub-CHERWIN_FRPC-181717?style=flat-square&logo=github" alt="GitHub">
    </a>
  </p>
</div>
