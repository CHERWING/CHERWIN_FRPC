#!/system/bin/sh
MODDIR=${0%/*}
[ -d "$MODDIR/conf" ] || MODDIR="/data/adb/modules/CHERWIN_FRPC"

# 停止 frpc
if [ -f "$MODDIR/run/frpc.pid" ]; then
    pid=$(cat "$MODDIR/run/frpc.pid")
    kill "$pid" 2>/dev/null
    rm -f "$MODDIR/run/frpc.pid"
fi

# 清理备份文件
rm -f /data/local/tmp/.frpc_config_backup 2>/dev/null

# 清理日志
rm -f "$MODDIR/log/frpc.log" "$MODDIR/log/service.log" 2>/dev/null
