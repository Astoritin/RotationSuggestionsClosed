#!/system/bin/sh
MODDIR=${0%/*}

MODULE_PROP="$MODDIR/module.prop"
MOD_INTRO="Stop showing rotation suggestions button."

update_config_var() {
    key_name="$1"
    key_value="$2"
    file_path="$3"

    if [ -z "$key_name" ] || [ -z "$key_value" ] || [ -z "$file_path" ]; then
        return 1
    elif [ ! -f "$file_path" ]; then
        return 2
    fi

    sed -i "/^${key_name}=/c\\${key_name}=${key_value}" "$file_path"
    result_update_value=$?
    return "$result_update_value"

}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

settings put secure show_rotation_suggestions 0

DESC_RS=""
while true; do
    [ -f "$MODDIR/update" ] && exit 0
    result_rs="$(settings get secure show_rotation_suggestions)"
    if [ $result_rs = 0 ]; then
        DESC_RS="OFF"
    elif [ $result_rs = 1 ]; then
        DESC_RS="ON"
    fi
    DESCRIPTION="[⚙️Button: ${DESC_RS}] $MOD_INTRO"
    update_config_var "description" "$DESCRIPTION" "$MODULE_PROP"
    sleep 3
done
