#!/system/bin/sh
MODDIR=${0%/*}

# 模块安装脚本界面美化 - 修复乱码问题
# 使用标准字符而不是扩展的 ASCII 块字符，因为很多 Android recovery/KernelSU 终端不支持宽字符
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
ui_print "  > 模块版本: v1.0.0 (核心 v0.69.1)"
ui_print "  > 模块作者: CHERWIN"
ui_print "  > 支持面板: KernelSU / Magisk"
ui_print " ===================================================="
ui_print " "

ui_print " [1/3] [*] 正在释放模块文件..."
# 文件释放由系统接管，这里只需提示进度

ui_print " [2/3] [*] 正在配置文件与目录权限..."
set_perm_recursive $MODDIR 0 0 0755 0644
set_perm_recursive $MODDIR/bin 0 0 0755 0755
set_perm $MODDIR/action.sh 0 0 0755 0755
set_perm $MODDIR/service.sh 0 0 0755 0755
sleep 1

ui_print " [3/3] [+] 权限设置完成！"
ui_print " "
ui_print " ----------------------------------------------------"
ui_print "  [+] 安装大功告成！"
ui_print " ----------------------------------------------------"
ui_print " "
ui_print "  [ 使用指南 ]："
ui_print "  1. 重启设备后，frpc 将自动在后台运行。"
ui_print "  2. 在 KernelSU 模块列表点击「启动」切换服务。"
ui_print "  3. 点击模块「WebUI」按钮打开管理面板。"
ui_print "  4. 手动访问: http://127.0.0.1:8099"
ui_print " "
ui_print "  感谢使用 CHERWIN 专属定制模块！"
ui_print " "
