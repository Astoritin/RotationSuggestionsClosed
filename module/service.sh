#!/system/bin/sh
MODDIR=${0%/*}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

settings put secure show_rotation_suggestions 0
