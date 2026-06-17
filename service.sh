#!/system/bin/sh
MODDIR=${0%/*}
[ -d "$MODDIR/conf" ] || MODDIR="/data/adb/modules/CHERWIN_FRPC"

chmod 755 $MODDIR/bin/frpc

mkdir -p $MODDIR/log
mkdir -p $MODDIR/run

# 开机恢复配置：有备份则无条件使用（已知可用的配置）
if [ -f /data/local/tmp/.frpc_config_backup ]; then
    cp /data/local/tmp/.frpc_config_backup "$MODDIR/conf/frpc.toml"
    echo "[$(date)] Restored frpc.toml from backup (overwrote extracted file)" >> $MODDIR/log/service.log
elif [ ! -s "$MODDIR/conf/frpc.toml" ]; then
    if [ -f "$MODDIR/conf/frpc.toml.template" ]; then
        cp "$MODDIR/conf/frpc.toml.template" "$MODDIR/conf/frpc.toml"
        echo "[$(date)] Created frpc.toml from template" >> $MODDIR/log/service.log
    fi
fi

update_description() {
    local pid=""
    if [ -f "$MODDIR/run/frpc.pid" ]; then
        pid=$(cat "$MODDIR/run/frpc.pid")
        if kill -0 "$pid" 2>/dev/null; then
            sed -i "/^description=/c\description=▶️ 运行中 (PID: $pid)" "$MODDIR/module.prop"
            return
        fi
    fi
    sed -i "/^description=/c\description=⏹️ 已停止" "$MODDIR/module.prop"
}

check_battery_and_stop() {
    while true; do
        if [ -f "$MODDIR/run/frpc.pid" ]; then
            local pid=$(cat "$MODDIR/run/frpc.pid")
            if kill -0 "$pid" 2>/dev/null; then
                local battery_level=$(dumpsys battery | grep "level:" | awk '{print $2}')
                local status=$(dumpsys battery | grep "status:" | awk '{print $2}')
                if [ "$battery_level" -lt 20 ] && [ "$status" != "2" ] && [ "$status" != "5" ]; then
                    kill "$pid"
                    rm -f "$MODDIR/run/frpc.pid"
                    echo "[$(date)] Auto-stopped frpc: Battery critical (${battery_level}%) and not charging." >> "$MODDIR/log/service.log"
                    update_description
                fi
            fi
        fi
        sleep 300
    done
}

start_frpc() {
    local bin=$MODDIR/bin/frpc
    local conf=$MODDIR/conf/frpc.toml
    local log=$MODDIR/log/frpc.log

    if [ -f $MODDIR/run/frpc.pid ]; then
        local pid=$(cat $MODDIR/run/frpc.pid)
        if kill -0 $pid 2>/dev/null; then
            echo "[$(date)] frpc is already running with PID $pid" >> $MODDIR/log/service.log
            return
        fi
    fi

    if [ -f "$conf" ]; then
        nohup $bin -c $conf > $log 2>&1 &
        local pid=$!
        echo $pid > $MODDIR/run/frpc.pid
        echo "[$(date)] Started frpc with PID $pid" >> $MODDIR/log/service.log
        update_description
        # 等待 frpc 成功连接服务端后再备份（最多 30s）
        for i in 1 2 3 4 5 6; do
            if grep -q "login to server success" "$log" 2>/dev/null; then
                cp "$conf" /data/local/tmp/.frpc_config_backup 2>/dev/null
                echo "[$(date)] Config backed up after successful login" >> $MODDIR/log/service.log
                break
            fi
            sleep 5
        done
    else
        echo "[$(date)] Error: Config file not found at $conf" >> $MODDIR/log/service.log
    fi
}

stop_frpc() {
    if [ -f "$MODDIR/run/frpc.pid" ]; then
        local pid=$(cat "$MODDIR/run/frpc.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo "[$(date)] Stopped frpc (PID $pid)" >> $MODDIR/log/service.log
        fi
        rm -f "$MODDIR/run/frpc.pid"
    fi
    update_description
}

# Wait for network
for i in 1 2 3 4 5 6 7 8; do
    if getprop net.dns1 >/dev/null 2>&1 && [ -n "$(getprop net.dns1)" ]; then
        break
    fi
    sleep 2
done

start_frpc

nohup check_battery_and_stop > /dev/null 2>&1 &
