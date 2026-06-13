#!/system/bin/sh
echo "Content-Type: application/json"
echo ""

MODDIR="/data/adb/modules/CHERWIN_FRPC"
PID_FILE="$MODDIR/run/frpc.pid"
CONF_FILE="$MODDIR/conf/frpc.toml"
SERVICE_LOG="$MODDIR/log/service.log"

action=$(echo "$QUERY_STRING" | grep -o 'action=[^&]*' | cut -d= -f2)

is_running() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

get_mem() {
    if is_running; then
        pid=$(cat "$PID_FILE")
        mem=$(dumpsys meminfo "$pid" | grep "TOTAL PSS:" | awk '{print $3}')
        if [ -n "$mem" ]; then
            echo "$((mem / 1024)) MB"
            return
        fi
    fi
    echo "0 MB"
}

get_server_status() {
    if ! is_running; then
        echo "未启�?
        return
    fi
    if [ -f "$MODDIR/log/frpc.log" ]; then
        last_event=$(grep -E "login to server success|connect to server error|login to server failed|work connection closed|token is not valid|i/o timeout|connection refused" "$MODDIR/log/frpc.log" | tail -n 1)
        if echo "$last_event" | grep -q "success"; then
            echo "已连�?
        elif echo "$last_event" | grep -q -E "error|failed|closed|invalid|timeout|refused"; then
            echo "连接异常"
        else
            echo "连接�?.."
        fi
    else
        echo "无日�?
    fi
}

get_proxies_status() {
    if ! is_running || [ ! -f "$MODDIR/log/frpc.log" ]; then
        echo "[]"
        return
    fi
    
    # Extract proxy names from config using awk
    proxy_names=$(awk -F'"' '/\[\[proxies\]\]/{f=1} f && /^name = / {print $2; f=0}' "$CONF_FILE")
    
    # If no proxies configured
    if [ -z "$proxy_names" ]; then
        echo "[]"
        return
    fi

    # Build JSON array manually
    json_array="["
    first=1
    
    for name in $proxy_names; do
        status="未知"
        # Check logs for this specific proxy
        # success: [name] start proxy success
        # error: [name] start error: port already used
        last_log=$(grep "\\[$name\\]" "$MODDIR/log/frpc.log" | tail -n 1)
        
        if echo "$last_log" | grep -q "start proxy success"; then
            status="在线"
        elif echo "$last_log" | grep -q "error"; then
            status="失败"
        fi
        
        if [ $first -eq 0 ]; then
            json_array="$json_array,"
        fi
        json_array="$json_array{\"name\": \"$name\", \"status\": \"$status\"}"
        first=0
    done
    
    json_array="$json_array]"
    echo "$json_array"
}


case "$action" in
    "status")
        server_status=$(get_server_status)
        proxies_json=$(get_proxies_status)
        if is_running; then
            pid=$(cat "$PID_FILE")
            uptime_str=$(ps -o etime -p "$pid" | tail -n 1 | tr -d ' ')
            mem=$(get_mem)
            echo "{\"status\": \"running\", \"pid\": \"$pid\", \"uptime\": \"$uptime_str\", \"mem\": \"$mem\", \"server_status\": \"$server_status\", \"proxies\": $proxies_json}"
        else
            echo "{\"status\": \"stopped\", \"pid\": \"N/A\", \"uptime\": \"0\", \"mem\": \"0 MB\", \"server_status\": \"$server_status\", \"proxies\": []}"
        fi
        ;;
    "start")
        if ! is_running; then
            $MODDIR/bin/frpc -c "$CONF_FILE" > "$MODDIR/log/frpc.log" 2>&1 &
            new_pid=$!
            echo $new_pid > "$PID_FILE"
            echo "[$(date)] WebUI: Started frpc with PID $new_pid" >> "$SERVICE_LOG"
            echo "{\"success\": true, \"message\": \"已启动\"}"
        else
            echo "{\"success\": false, \"message\": \"已经运行\"}"
        fi
        ;;
    "stop")
        if is_running; then
            pid=$(cat "$PID_FILE")
            kill "$pid"
            rm -f "$PID_FILE"
            echo "[$(date)] WebUI: Stopped frpc (PID $pid)" >> "$SERVICE_LOG"
            echo "{\"success\": true, \"message\": \"已停止\"}"
        else
            echo "{\"success\": false, \"message\": \"未运行\"}"
        fi
        ;;
    "restart")
        if is_running; then
            pid=$(cat "$PID_FILE")
            kill "$pid"
            rm -f "$PID_FILE"
            sleep 1
        fi
        $MODDIR/bin/frpc -c "$CONF_FILE" > "$MODDIR/log/frpc.log" 2>&1 &
        new_pid=$!
        echo $new_pid > "$PID_FILE"
        echo "[$(date)] WebUI: Restarted frpc with PID $new_pid" >> "$SERVICE_LOG"
        echo "{\"success\": true, \"message\": \"已重启\"}"
        ;;
    "get_config")
        config_content=$(cat "$CONF_FILE" 2>/dev/null)
        echo "{ \"config\": \"$(echo "$config_content" | base64 -w 0)\" }"
        ;;
    "get_logs")
        log_type=$(echo "$QUERY_STRING" | grep -o 'type=[^&]*' | cut -d= -f2)
        if [ "$log_type" = "frpc" ]; then
            log_content=$(tail -n 100 "$MODDIR/log/frpc.log" 2>/dev/null)
        else
            log_content=$(tail -n 100 "$SERVICE_LOG" 2>/dev/null)
        fi
        echo "{ \"logs\": \"$(echo "$log_content" | base64 -w 0)\" }"
        ;;
    "clear_logs")
        > "$MODDIR/log/frpc.log"
        > "$SERVICE_LOG"
        echo "{\"success\": true, \"message\": \"日志已清空\"}"
        ;;
    *)
        echo "{\"error\": \"Unknown action\"}"
        ;;
esac
