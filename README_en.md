<p align="center">
  <img src="https://img.shields.io/badge/FRPC-v0.69.1-blue?style=flat-square" alt="FRPC">
  <img src="https://img.shields.io/badge/module-v1.2.2-green?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/support-KernelSU%20%7C%20Magisk-orange?style=flat-square" alt="Support">
  <img src="https://img.shields.io/badge/arch-arm64-red?style=flat-square" alt="Arch">
</p>

<div align="center">
  <h1>CHERWIN FRPC</h1>
  <p>High-Performance FRP Reverse Proxy Client · KernelSU / Magisk Edition</p>
  <p>
    <a href="README.md">中文</a> ·
    <a href="README_en.md">English</a>
  </p>
</div>

---

## Introduction

CHERWIN FRPC is an intranet penetration module built for the Android Root environment (KernelSU & Magisk). It integrates the latest FRPC core (v0.69.1) and comes with a management panel powered by KernelSU's native WebView API — no busybox, no httpd required.

---

## Features

### 🚀 Core
- **Full protocol support** — TCP / UDP / HTTP / HTTPS / STCP / XTCP / SUDP
- **Token authentication** — Secure communication with your server
- **Load balancing & health check** — Automatic multi-node failover
- **Store persistence** — FRP v0.52+ store feature, survives reboot

### 🖥️ WebUI Management Panel
- **Real-time status** — Process health, server connection, per-proxy online/offline
- **Watchdog** — Auto-detects log errors and restarts frpc on failure
- **Schedule timer** — Set on/off hours, auto-sleep outside window
- **Network guard** — Auto-stop on no network, auto-start on recovery
- **Battery saver** — Configurable threshold (default 20%)
- **Hot-reload config** — Edit `frpc.toml` online, save = restart
- **Built-in config guide** — Complete tutorial and proxy templates

### 💾 Config Persistence
- Config auto-backup to `/data/local/tmp/`, survives module updates
- Dual fallback: installer + boot script both restore from backup

### 📜 Standalone Scripts
- `start.sh` / `stop.sh` / `restart.sh` — Run directly from MT Manager
- `uninstall.sh` — Clean uninstall
- `action.sh` — Toggle via module list "▶" button

---

## Installation

### Prerequisites
- Android device with Root access
- **KernelSU** (recommended) or **Magisk** installed
- **arm64 (aarch64)** architecture only

### Steps

```bash
# 1. Download the latest release ZIP from GitHub Releases
# 2. Flash: KernelSU / Magisk → Modules → Install from storage → Select ZIP
# 3. Reboot
```

### First-Time Setup

1. Open KernelSU → Module list → Click CHERWIN FRPC's **WebUI（<>）** button
2. Go to "Config" tab
3. Update `serverAddr` and `auth.token` with your server info
4. Click "Save" — frpc auto-restarts and connects

> ⚠️ The panel must be opened from KernelSU's built-in WebView (requires `ksu.exec()` API). External browser access is not supported.

---

## Usage

### Basic Flow
1. Fill in server address and token → Save
2. Add proxy tunnels (TCP / HTTP / HTTPS, etc.)
3. frpc starts automatically — check status on dashboard

### Schedule Timer (Power Saving)
- Enable "Schedule", set daily on/off hours (e.g., 08:00–22:00)
- Outside schedule: frpc stops and enters long sleep

### Watchdog (Anti-Disconnect)
- Enable "Fault Restart" — watchdog checks logs every 20s
- Connection error detected without success → auto-restart frpc

### Network Guard
- No network detected → auto-stop frpc
- Network restored → auto-start frpc

### Battery Saver
- Battery below threshold (default 20%) and not charging → auto-stop
- Charging resumes → scheduler auto-starts frpc

---

## Config Persistence

| Trigger | Backup Content | Backup Path |
|---------|---------------|-------------|
| WebUI config save | frpc.toml | `/data/local/tmp/.frpc_config_backup` |
| WebUI settings save | settings.conf | `/data/local/tmp/.frpc_settings_backup` |
| Boot (successful login) | frpc.toml | `/data/local/tmp/.frpc_config_backup` |
| Module update | — | Installer auto-restores from backup |

---

## FAQ

<details>
<summary><b>Q: WebUI won't open?</b></summary>
Open from KernelSU module list by clicking the "WebUI（<>）" button, not from an external browser.
</details>

<details>
<summary><b>Q: Status keeps showing "Checking"?</b></summary>
Close the page and re-open it via the WebUI button.
</details>

<details>
<summary><b>Q: Will I lose config after updating?</b></summary>
Not with v1.2.0+. Config is auto-backed up to /data/local/tmp/ and restored on flash.
</details>

<details>
<summary><b>Q: Connection error but no auto-recovery?</b></summary>
Check if "Fault Restart" is enabled in module settings and the watchdog interval is reasonable (default 20s). Also verify server address and port in frpc.toml.
</details>

<details>
<summary><b>Q: Port conflict?</b></summary>
The frpc Dashboard defaults to port 7400. Change webServer.port in your config if needed.
</details>

---

## Changelog

### v1.2.2 (Current)
- 🔧 loginFailExit forced off
- 🛡️ Watchdog: instant restart on error detection
- 🔌 Port release wait — eliminates `bind: address already in use`
- 📜 Standalone scripts (start/stop/restart)
- ⏰ Schedule timer, network guard, battery saver
- ⚙️ WebUI settings page

### v1.2.1
- 🗑️ uninstall.sh
- 💾 Config backup extended to settings.conf

### v1.2.0
- 🛡️ Config preservation mechanism
- 🔄 Auto-recovery at boot
- 🧩 First-install template loading
- 📊 Multi-fallback memory reading

### v1.1.0
- 🎯 WebUI rewritten (`ksu.exec()` API)
- 🎨 iOS-style UI
- 📖 Built-in config guide

### v1.0.0
- 🎉 Initial release
- 🔄 FRPC core v0.69.1

---

## Credits

- [FRP](https://github.com/fatedier/frp) — Open-source reverse proxy tool
- [LINUX DO](https://linux.do) — Open-source technology community
- KernelSU WebView API — Native management panel support

---

<div align="center">
  <p>Built with ❤️ by <a href="https://github.com/CHERWING">CHERWIN</a></p>
  <p>
    <a href="https://github.com/CHERWING/CHERWIN_FRPC">
      <img src="https://img.shields.io/badge/GitHub-CHERWIN_FRPC-181717?style=flat-square&logo=github" alt="GitHub">
    </a>
  </p>
</div>
