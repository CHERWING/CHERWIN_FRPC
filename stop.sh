#!/system/bin/sh
MODDIR=${0%/*}
[ -d "$MODDIR/conf" ] || MODDIR="/data/adb/modules/CHERWIN_FRPC"
PID_FILE="$MODDIR/run/frpc.pid"

if [ -f "$PID_FILE" ]; then
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        echo "frpc 已停止 (PID: $pid)"
    else
        echo "frpc 未在运行"
    fi
    rm -f "$PID_FILE"
else
    echo "frpc 未在运行"
fi

sed -i "/^description=/c\description=⏹️ 已停止" "$MODDIR/module.prop"
