#!/system/bin/sh
MODDIR=${0%/*}

chmod 755 $MODDIR/bin/frpc
chmod 755 $MODDIR/webroot/cgi-bin/*

mkdir -p $MODDIR/log
mkdir -p $MODDIR/run

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

# Function to start service
start_frpc() {
    local bin=$MODDIR/bin/frpc
    local conf=$MODDIR/conf/frpc.toml
    local log=$MODDIR/log/frpc.log
    
    # Check if running
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

# Start httpd for custom WebUI using busybox (port 8099)
start_httpd() {
    if ! pgrep -f "busybox httpd -p 8099" > /dev/null; then
        busybox httpd -p 8099 -h $MODDIR/webroot
        echo "[$(date)] Started WebUI on port 8099" >> $MODDIR/log/service.log
    fi
}

# Wait for network
for i in 1 2 3 4 5 6 7 8; do
    if getprop net.dns1 >/dev/null 2>&1 && [ -n "$(getprop net.dns1)" ]; then
        break
    fi
    sleep 2
done

start_frpc
start_httpd

nohup check_battery_and_stop > /dev/null 2>&1 &
