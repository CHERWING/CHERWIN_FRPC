[中文](README.md) | [English](README_en.md)

# CHERWIN FRPC

> High-Performance FRP Reverse Proxy Client (KernelSU / Magisk Edition)

CHERWIN FRPC is an intranet penetration module built for the Android Root environment (KernelSU & Magisk). It integrates the latest FRPC core (v0.69.1) and comes with a management panel powered by KernelSU's native WebView API, allowing you to deploy network services on your phone at lightning speed.

## Key Features

- **Minimalist Deployment**: Flash with one click, auto-starts daemon on boot
- **KernelSU Native Management Panel**: Uses `ksu.exec()` API to execute shell commands directly — no HTTP server needed, open via the "WebUI" button in the module manager
- **Real-time Monitoring**: FRP process status & PID, server connection status, per-proxy tunnel connectivity, uptime and memory usage
- **Hot-Reload Config**: Edit `frpc.toml` in the panel, save via base64 encoding, auto-restart with one click
- **Config Preservation**: On update, config is automatically backed up to `/data/local/tmp/` and restored — never lose your settings again
- **First-Install Friendly**: Automatically loads `frpc.toml.template` when no config exists, just save to generate
- **Built-in Config Guide**: Complete configuration manual embedded in the panel (basic config, proxy templates, Store persistence, FAQ)
- **Low Battery Protection**: Auto-stops frpc when battery is below 20% and not charging
- **Store Persistence**: Full support for FRP v0.52+ store feature, prevents disconnection after reboot

## Installation & Usage

### 1. Flash the Module
1. Download the latest `CHERWIN_FRPC_magisk_module.zip` release
2. Open **KernelSU** or **Magisk** manager
3. Go to "Modules" page, click "Install from storage", select the downloaded ZIP
4. **Reboot** your device after installation

### 2. Access the Management Panel
In the KernelSU module list, find `CHERWIN FRPC` and click the **WebUI icon (`<>`)** on the right side. The panel will open in KernelSU's built-in WebView.

> Note: The panel must be opened from within the KernelSU module manager (requires `ksu.exec()` API). External browser access is not supported.

### 3. First-Time Setup
After first install, open the WebUI, go to the "Config" tab, update `serverAddr` and `auth.token` with your FRP server details, and click "Save" to auto-restart.

## Panel Features

### Status
Real-time FRP status — process health (green pulsing indicator), server connection, proxy tunnel states, uptime and memory usage

### Config
Edit `frpc.toml` online, save to auto-restart frpc. On first install, the template is loaded automatically. The config tab also includes a complete configuration guide.

### Logs
View frpc runtime logs and service daemon logs, with one-click clear

## Config Preservation

Starting from v1.2.0, the module automatically backs up your config to `/data/local/tmp/.frpc_config_backup` (outside the module directory):

- **At boot**: After service.sh starts frpc and it successfully connects to the server
- **On WebUI save**: After clicking "Save", once frpc reconnects successfully
- **On toggle**: After starting via the lightning icon, once connection succeeds

When flashing a new version, the installer restores config from backup. service.sh also performs a fallback recovery at boot to ensure your config is never lost.

## FAQ

**Q: The panel shows "Please open from KernelSU module manager"?**
A: The management panel relies on KernelSU's `ksu.exec()` API. Please open it by clicking the "WebUI" button in the module list, not from an external browser.

**Q: How to manually start/stop frpc?**
A: Click the **lightning icon (⚡)** on the module in KernelSU's module list to toggle start/stop, or use the Start/Stop buttons in the management panel.

**Q: What if I lose my config after updating?**
A: This won't happen with v1.2.0+. If upgrading from an older version, you'll need to re-edit your config once after the first flash. Subsequent updates will preserve it automatically.

## Changelog

- **v1.2.1** — Added uninstall.sh, various fixes
- **v1.2.0** — Config preservation mechanism, auto-recovery at boot, first-install template loading, multi-fallback memory reading, multiple bug fixes
- **v1.1.0** — WebUI rewritten: uses `ksu.exec()` API, iOS-style UI, built-in config guide, base64 config saving
- **v1.0.0** — Initial release: FRPC core v0.69.1, WebUI control panel, Store persistence support

## License

- Build scripts and management panel originally developed by **CHERWIN**
- Core binary [frpc](https://github.com/fatedier/frp) belongs to original author fatedier, licensed under Apache-2.0
