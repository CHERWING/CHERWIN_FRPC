#!/system/bin/sh
MODDIR=${0%/*}

case "$1" in
    start)
        if [ -f "$MODDIR/bin/frpc" ] && [ -f "$MODDIR/conf/frpc.toml" ]; then
            nohup $MODDIR/bin/frpc -c $MODDIR/conf/frpc.toml > $MODDIR/log/frpc.log 2>&1 &
            echo $! > $MODDIR/run/frpc.pid
        fi
        ;;
    *)
        am start -a android.intent.action.VIEW -d "http://127.0.0.1:8099"
        ;;
esac
