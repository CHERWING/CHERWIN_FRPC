#!/system/bin/sh
MODDIR=${0%/*}
MODID=CHERWIN_FRPC
PID_FILE="$MODDIR/run/frpc.pid"
CONF_FILE="$MODDIR/conf/frpc.toml"
LOG_FILE="$MODDIR/log/frpc.log"

update_description() {
    local desc="$1"
    sed -i "/^description=/c\description=$desc" "$MODDIR/module.prop"
}

toggle_frpc() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$PID_FILE"
            update_description "⏹️ 已停止"
            return 0
        fi
    fi
    rm -f "$PID_FILE"
    if [ -f "$CONF_FILE" ]; then
        nohup $MODDIR/bin/frpc -c "$CONF_FILE" > "$LOG_FILE" 2>&1 &
        local new_pid=$!
        echo $new_pid > "$PID_FILE"
        update_description "▶️ 运行中 (PID: $new_pid)"
    fi
}

toggle_frpc
