#!/system/bin/sh
MODDIR=${0%/*}

# Set executable permissions
chmod 755 $MODDIR/bin/frpc
chmod 755 $MODDIR/webroot/cgi-bin/*

# Create log and run directories
mkdir -p $MODDIR/log
mkdir -p $MODDIR/run

# Function to check battery
check_battery_and_stop() {
    while true; do
        if [ -f "$MODDIR/run/frpc.pid" ]; then
            local pid=$(cat "$MODDIR/run/frpc.pid")
            # Only check if process is actually running
            if kill -0 "$pid" 2>/dev/null; then
                # Get battery level and charging status via dumpsys
                local battery_level=$(dumpsys battery | grep "level:" | awk '{print $2}')
                local status=$(dumpsys battery | grep "status:" | awk '{print $2}')
                
                # status 2 means charging, 5 means full. If it's not 2 or 5, it's discharging.
                # Only stop if level < 20 and not charging
                if [ "$battery_level" -lt 20 ] && [ "$status" != "2" ] && [ "$status" != "5" ]; then
                    kill "$pid"
                    rm -f "$MODDIR/run/frpc.pid"
                    echo "[$(date)] Auto-stopped frpc: Battery critical (${battery_level}%) and not charging." >> "$MODDIR/log/service.log"
                fi
            fi
        fi
        # Check every 5 minutes (300 seconds)
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
        # Use busybox nohup to avoid background job issues
        nohup $bin -c $conf > $log 2>&1 &
        local pid=$!
        echo $pid > $MODDIR/run/frpc.pid
        echo "[$(date)] Started frpc with PID $pid" >> $MODDIR/log/service.log
    else
        echo "[$(date)] Error: Config file not found at $conf" >> $MODDIR/log/service.log
    fi
}

# Start httpd for custom WebUI using busybox (port 8099)
start_httpd() {
    if ! pgrep -f "busybox httpd -p 8099" > /dev/null; then
        busybox httpd -p 8099 -h $MODDIR/webroot
        echo "[$(date)] Started WebUI on port 8099" >> $MODDIR/log/service.log
    fi
}

start_frpc
start_httpd

# Start battery monitor daemon in background
nohup check_battery_and_stop > /dev/null 2>&1 &
