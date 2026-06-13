#!/system/bin/sh

MODDIR=${0%/*}

# Start web interface on click via intent to default browser
am start -a android.intent.action.VIEW -d "http://127.0.0.1:8099" -n com.android.chrome/com.google.android.apps.chrome.Main || am start -a android.intent.action.VIEW -d "http://127.0.0.1:8099"
