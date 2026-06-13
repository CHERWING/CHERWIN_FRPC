[中文](README.md) | [English](README_en.md)

# CHERWIN FRPC 🚀

> ⚡ High-Performance FRP Reverse Proxy Client (KernelSU / Magisk Edition)

CHERWIN FRPC is an intranet penetration module specifically built for the Android Root environment (KernelSU & Magisk). It integrates the latest FRPC core (v0.69.1) and comes with a powerful, elegant, out-of-the-box WebUI control panel, allowing you to deploy network services on your phone at lightning speed.

## ✨ Key Features

- **🚀 Minimalist Deployment**: Flash with one click, auto-starts daemon process on boot.
- **🌐 Independent WebUI Panel**: Built-in lightweight HTTP service (default port `8099`), say goodbye to tedious CLI operations.
- **📊 Real-time Status Monitoring**:
  - Monitors FRP core process survival and PID.
  - **Real-time detection of connection status with the main server** (Online, Offline, Error Reason Analysis).
  - **Independent status detection for each proxy channel**, visually displaying which tunnels are successful and which have failed.
  - Device memory usage and continuous running time statistics.
- **📝 Hot Reload Configuration**: Edit `frpc.toml` directly in the WebUI, save and restart the service smoothly with one click.
- **📖 Built-in Comprehensive Documentation**: The control panel embeds a complete configuration manual (including basic config, Nginx reverse proxy practices, Store persistence, common proxy templates, etc.), making it easy for beginners to start.
- **💾 Store Dynamic Persistence**: Fully supports the `store` feature of FRP v0.52+, preventing loss of connection after reboot.

---

## 📦 Installation & Usage

### 1. Flash the Module
1. Download the latest `CHERWIN_FRPC_magisk_module.zip` release package.
2. Open **KernelSU** or **Magisk** manager.
3. Go to the "Modules" page, click "Install from storage", and select the downloaded ZIP file.
4. After installation is complete, **reboot your device**.

### 2. Access the Web Control Panel
- **Shortcut**: In the KernelSU module list, find `CHERWIN_FRPC`, click the **Settings gear (or `< >`) icon** on the right, and the system will automatically invoke the browser to open the panel.
- **Manual Access**: Open any browser on your phone and visit: `http://127.0.0.1:8099`

---

## 🛠️ Panel Features Overview

### Dashboard (Status Monitoring)
Real-time control of FRP's running status. Visually displays whether the main process is alive, the handshake status with the remote server, and the connectivity of every TCP/HTTP/HTTPS tunnel listed below.

### Config Editor (Parameter Configuration)
Edit the TOML configuration file online. No more using file managers (like MT Manager) to find files in deep directories. Click "Save and Hot Restart" after editing to take effect immediately.

### Logs (Running Logs)
No need to SSH into your phone. Directly pull the running Debug logs of the `frpc` core and the panel daemon scripts on the web page. Comes with keyword highlight parsing.

### Docs (Configuration Manual)
You don't need to search the web for FRP tutorials. The top of the panel embeds a complete set of practical manuals, and code snippets can be copied with a click.

---

## 💡 Typical Use Cases

1. **📱 Turn Your Phone into a Portable Cloud Drive**: With FRP's `store` plugin, mount your phone's `/sdcard` directory to the public internet, and read/write phone files on your computer anytime, anywhere.
2. **🌍 Public Access for LAN Services**: Run website environments or game private servers built with Termux / KSUD on your phone, and map them to public domain names quickly through configuration.
3. **💻 Remote SSH Operation**: SSH log in to your Android terminal from anywhere via TCP penetration.

---

## ⚠️ Notes

1. The built-in FRPC core version of this module is `v0.69.1`, and the configuration format has been fully upgraded to **TOML**. The old `ini` format is no longer supported, so please pay attention to syntax standards.
2. If your WebUI cannot save the configuration, please check if other modules have interfered with the write permissions of `/data/adb/modules/`.
3. Long-term, high-concurrency network penetration may increase battery consumption and heat on the phone. Please enable it according to actual needs.

---

## 📄 License Declaration

- The build scripts and WebUI control panel of this module are originally developed by **CHERWIN**.
- The core binary file [frpc](https://github.com/fatedier/frp) belongs to the original author fatedier and follows the Apache-2.0 License.