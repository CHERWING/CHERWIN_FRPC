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

# 加载自定义设置（优先从备份恢复）
SETTINGS_FILE="$MODDIR/conf/settings.conf"
SETTINGS_BACKUP="/data/local/tmp/.frpc_settings_backup"
if [ -f "$SETTINGS_BACKUP" ]; then
    if ! diff "$SETTINGS_FILE" "$SETTINGS_BACKUP" >/dev/null 2>&1; then
        cp "$SETTINGS_BACKUP" "$SETTINGS_FILE" 2>/dev/null
        echo "[$(date)] Restored settings.conf from backup" >> $MODDIR/log/service.log
    fi
fi
[ -f "$SETTINGS_FILE" ] && . "$SETTINGS_FILE"
SCHEDULER_ENABLED=${SCHEDULER_ENABLED:-0}
SCHEDULER_START=${SCHEDULER_START:-08:00}
SCHEDULER_END=${SCHEDULER_END:-22:00}
CHECK_INTERVAL=${CHECK_INTERVAL:-60}
SLEEP_MAX=${SLEEP_MAX:-3600}
NETWORK_GUARD=${NETWORK_GUARD:-1}
FAULT_RESTART=${FAULT_RESTART:-1}
BATTERY_PROTECT=${BATTERY_PROTECT:-1}
BATTERY_LEVEL=${BATTERY_LEVEL:-20}
WATCHDOG_INTERVAL=${WATCHDOG_INTERVAL:-20}

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
        sleep 300
        [ "$BATTERY_PROTECT" = "1" ] || continue
        if [ -f "$MODDIR/run/frpc.pid" ]; then
            local pid=$(cat "$MODDIR/run/frpc.pid")
            if kill -0 "$pid" 2>/dev/null; then
                local battery_level=$(dumpsys battery | grep "level:" | awk '{print $2}')
                local status=$(dumpsys battery | grep "status:" | awk '{print $2}')
                if [ "$battery_level" -lt "$BATTERY_LEVEL" ] && [ "$status" != "2" ] && [ "$status" != "5" ]; then
                    kill "$pid"
                    rm -f "$MODDIR/run/frpc.pid"
                    echo "[$(date)] Auto-stopped frpc: Battery critical (${battery_level}% < ${BATTERY_LEVEL}%) and not charging." >> "$MODDIR/log/service.log"
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
        # 注入 loginFailExit = false，防止首次失败后 frpc 自行退出
        if ! grep -q "^loginFailExit" "$conf" 2>/dev/null; then
            {
                echo "loginFailExit = false"
                echo ""
                cat "$conf"
            } > "$conf.tmp" && mv "$conf.tmp" "$conf"
            echo "[$(date)] Injected loginFailExit = false into config" >> $MODDIR/log/service.log
        fi
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
    # Wait for port 7400 to be released before next start
    local port_hex=$(printf "%04X" 7400)
    for i in 1 2 3 4 5; do
        grep -q ":$port_hex" /proc/net/tcp 2>/dev/null || break
        sleep 1
    done
    update_description
}

# 连接异常自动重启监测（自愈）
watchdog_connection() {
    echo "[$(date)] Watchdog started" >> "$MODDIR/log/service.log"
    while true; do
        # 重新加载设置（WebUI 修改后可即时生效）
        [ -f "$SETTINGS_FILE" ] && . "$SETTINGS_FILE"
        WATCHDOG_INTERVAL=${WATCHDOG_INTERVAL:-20}
        FAULT_RESTART=${FAULT_RESTART:-1}
        sleep "$WATCHDOG_INTERVAL"
        [ "$FAULT_RESTART" = "1" ] || continue
        if [ ! -f "$MODDIR/run/frpc.pid" ]; then
            continue
        fi
        local pid=$(cat "$MODDIR/run/frpc.pid")
        if ! kill -0 "$pid" 2>/dev/null; then
            echo "[$(date)] Watchdog: frpc died, restarting" >> "$MODDIR/log/service.log"
            start_frpc
            continue
        fi
        local recent=$(tail -n 3 "$MODDIR/log/frpc.log" 2>/dev/null)
        if echo "$recent" | grep -q "login to server success"; then
            :
        elif echo "$recent" | grep -Eq "connect to server error|login to server failed|i/o timeout|connection refused|i/o deadline"; then
            echo "[$(date)] Watchdog: errors detected, restarting frpc" >> "$MODDIR/log/service.log"
            stop_frpc
            start_frpc
        fi
    done
}

# 调度器主循环
scheduler_loop() {
    while true; do
        # 每次循环重新加载设置（WebUI 修改后可即时生效）
        [ -f "$SETTINGS_FILE" ] && . "$SETTINGS_FILE"
        # 备份设置（供下次刷入时恢复）
        cp "$SETTINGS_FILE" "$SETTINGS_BACKUP" 2>/dev/null
        SCHEDULER_ENABLED=${SCHEDULER_ENABLED:-0}
        SCHEDULER_START=${SCHEDULER_START:-08:00}
        SCHEDULER_END=${SCHEDULER_END:-22:00}
        CHECK_INTERVAL=${CHECK_INTERVAL:-60}
        SLEEP_MAX=${SLEEP_MAX:-3600}
        NETWORK_GUARD=${NETWORK_GUARD:-1}

        # ── 时间段检查 ──
        local in_schedule=1
        if [ "$SCHEDULER_ENABLED" = "1" ]; then
            local now=$(date +%H%M)
            local start_t=$(echo "$SCHEDULER_START" | tr -d ':')
            local end_t=$(echo "$SCHEDULER_END" | tr -d ':')
            if [ "$now" -lt "$start_t" ] || [ "$now" -ge "$end_t" ]; then
                in_schedule=0
            fi
        fi

        if [ "$in_schedule" = "0" ]; then
            stop_frpc
            echo "[$(date)] 调度器: 非运行时段 (${SCHEDULER_START}-${SCHEDULER_END}), 休眠 ${SLEEP_MAX}s" >> "$MODDIR/log/service.log"
            sleep "$SLEEP_MAX"
            continue
        fi

        # ── 网络检测 ──
        if [ "$NETWORK_GUARD" = "1" ]; then
            local net_ok=false
            ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1 && net_ok=true
            if ! $net_ok; then
                ping -c 1 -W 3 114.114.114.114 >/dev/null 2>&1 && net_ok=true
            fi
            if ! $net_ok && getprop net.dns1 >/dev/null 2>&1 && [ -n "$(getprop net.dns1)" ]; then
                net_ok=true
            fi
            if ! $net_ok; then
                stop_frpc
                echo "[$(date)] 调度器: 网络不可用, 等待 ${CHECK_INTERVAL}s" >> "$MODDIR/log/service.log"
                sleep "$CHECK_INTERVAL"
                continue
            fi
        fi

        # ── 启动 frpc（如未运行） ──
        start_frpc

        # ── 等待下次检查（自愈由独立的 watchdog 处理） ──
        sleep "$CHECK_INTERVAL"
    done
}

# Wait for network（首次启动等待）
for i in 1 2 3 4 5 6 7 8; do
    if getprop net.dns1 >/dev/null 2>&1 && [ -n "$(getprop net.dns1)" ]; then
        break
    fi
    sleep 2
done

start_frpc

nohup scheduler_loop > /dev/null 2>&1 &
nohup check_battery_and_stop > /dev/null 2>&1 &
nohup watchdog_connection > /dev/null 2>&1 &
