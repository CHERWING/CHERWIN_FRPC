#!/system/bin/sh
# 可靠获取模块目录：环境变量 → 硬编码 → 脚本路径
if [ -n "$MODPATH" ] && [ -d "$MODPATH" ]; then
    MODDIR="$MODPATH"
elif [ -d "/data/adb/modules/CHERWIN_FRPC" ]; then
    MODDIR="/data/adb/modules/CHERWIN_FRPC"
else
    MODDIR=${0%/*}
fi

# 架构检测 — 仅支持 arm64
ARCH=$(uname -m)
case "$ARCH" in
    aarch64|arm64)
        ARCH_NAME="arm64"
        ;;
    *)
        ui_print " "
        ui_print " ****************************************************"
        ui_print " *         架构不兼容 - 安装中止                   *"
        ui_print " ****************************************************"
        ui_print "  > 检测到架构: $ARCH"
        ui_print "  > 本模块仅支持 arm64 (aarch64) 设备"
        ui_print "  > 请下载对应架构的 frpc 二进制后重新打包"
        ui_print " "
        abort "  > 不支持的架构: $ARCH"
        ;;
esac

ui_print " "
ui_print " ****************************************************"
ui_print " *                                                  *"
ui_print " *   -----  ||  ||  ||||||  |||||   ||   ||  || ||  *"
ui_print " *  //      ||  ||  ||      ||   |  || | ||  || ||  *"
ui_print " *  ||      ||==||  ||||    |||||   || | ||  || ||  *"
ui_print " *  \\\\      ||  ||  ||      || \\\\   ||/ \\||  || ||  *"
ui_print " *   -----  ||  ||  ||||||  ||  \\\\  |/   \\|  || ||  *"
ui_print " *                                                  *"
ui_print " *               FRPC Client Module                 *"
ui_print " ****************************************************"
ui_print " "
ui_print " ===================================================="
ui_print "  > 模块名称: CHERWIN FRPC 客户端"
ui_print "  > 模块版本: v1.2.1 (核心 v0.69.1)"
ui_print "  > 模块作者: CHERWIN"
ui_print "  > 设备架构: $ARCH_NAME"
ui_print "  > 支持面板: KernelSU / Magisk"
ui_print " ===================================================="
ui_print " "

ui_print " [1/3] [*] 正在释放模块文件..."
# 文件释放由系统接管，这里只需提示进度

ui_print " [2/5] [*] 检测配置文件..."
BACKUP="/data/local/tmp/.frpc_config_backup"
if [ -f "$BACKUP" ]; then
    cp "$BACKUP" "$MODDIR/conf/frpc.toml" 2>/dev/null || cat "$BACKUP" > "$MODDIR/conf/frpc.toml" 2>/dev/null
    if [ -f "$MODDIR/conf/frpc.toml" ]; then
        ui_print "  > 已从备份恢复配置文件"
    else
        ui_print "  > ⚠ 备份存在但恢复失败 ($MODDIR)"
        ui_print "  > 将使用 ZIP 内默认配置，保留备份供开机恢复"
    fi
else
    ui_print "  > ⚠ 首次使用：请打开模块 WebUI → 配置页"
    ui_print "  >   修改参数后点击「保存」，再启动即可"
fi

ui_print " [3/5] [*] 正在配置文件与目录权限..."
set_perm_recursive $MODDIR 0 0 0755 0644
set_perm_recursive $MODDIR/bin 0 0 0755 0755
set_perm $MODDIR/action.sh 0 0 0755 0755
set_perm $MODDIR/service.sh 0 0 0755 0755
sleep 1

ui_print " [4/5] [+] 权限设置完成！"
ui_print " "
ui_print " [5/5] [+] 安装大功告成！"
ui_print " ----------------------------------------------------"
ui_print " ----------------------------------------------------"
ui_print " "
ui_print "  [ 使用指南 ]："
ui_print "  1. 重启设备后，frpc 将自动在后台运行。"
ui_print "  2. 在 KernelSU 模块列表点击「⚡」切换启动/停止。"
ui_print "  3. 点击模块「WebUI ( < > )」按钮打开管理面板。"
ui_print "  4. 管理面板需在 KernelSU WebView 内打开使用。"
ui_print " "
ui_print "  感谢使用 CHERWIN 专属定制模块！"
ui_print " "
