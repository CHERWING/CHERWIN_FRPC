#!/system/bin/sh
echo "Content-Type: application/json"
echo ""

MODDIR="/data/adb/modules/CHERWIN_FRPC"
CONF_FILE="$MODDIR/conf/frpc.toml"

# Busybox httpd 会将 POST 请求的 Body 直接传给 stdin
# 使用 cat 可以读取完整的多行内容，而 read 只能读取第一行
cat > "$CONF_FILE.tmp"

# 检查文件是否非空
if [ -s "$CONF_FILE.tmp" ]; then
    mv "$CONF_FILE.tmp" "$CONF_FILE"
    echo "{\"success\": true, \"message\": \"配置已保存\"}"
else
    rm -f "$CONF_FILE.tmp"
    echo "{\"success\": false, \"message\": \"保存失败：内容为空\"}"
fi
