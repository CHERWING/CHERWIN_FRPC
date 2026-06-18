#!/system/bin/sh
MODDIR=${0%/*}
[ -d "$MODDIR/conf" ] || MODDIR="/data/adb/modules/CHERWIN_FRPC"
PID_FILE="$MODDIR/run/frpc.pid"
CONF_FILE="$MODDIR/conf/frpc.toml"
LOG_FILE="$MODDIR/log/frpc.log"

# stop
if [ -f "$PID_FILE" ]; then
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        echo "frpc 已停止 (PID: $pid)"
    fi
    rm -f "$PID_FILE"
fi

# wait for port release
port_hex=$(printf "%04X" 7400)
for i in 1 2 3 4 5; do
    grep -q ":$port_hex" /proc/net/tcp 2>/dev/null || break
    sleep 1
done

# start
if [ -f "$CONF_FILE" ]; then
    nohup $MODDIR/bin/frpc -c "$CONF_FILE" > "$LOG_FILE" 2>&1 &
    new_pid=$!
    echo $new_pid > "$PID_FILE"
    sed -i "/^description=/c\description=▶️ 运行中 (PID: $new_pid)" "$MODDIR/module.prop"
    echo "frpc 已重启 (PID: $new_pid)"
else
    echo "错误: 配置文件不存在"
    exit 1
fi
