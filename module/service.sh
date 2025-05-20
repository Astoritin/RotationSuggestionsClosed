#!/system/bin/sh
MODDIR=${0%/*}

MODULE_PROP="$MODDIR/module.prop"
MOD_INTRO="A Magisk module to disable useless rotation suggestion button as rotating screen each time."

. "$MODDIR/aautilities.sh"

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

settings put secure show_rotation_suggestions 0

DESC_RS=""
while true; do
    result_rs="$(settings get secure show_rotation_suggestions)"
    if [ $result_rs = 0 ]; then
        DESC_RS="Closed"
    elif [ $result_rs = 1 ]; then
        DESC_RS="Enabled"
    fi
    DESCRIPTION="[⚙️Rotation suggestion button: $DESC_RS] $MOD_INTRO"
    update_config_value "description" "$DESCRIPTION" "$MODULE_PROP"
    sleep 3
done
