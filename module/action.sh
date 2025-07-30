#!/system/bin/sh
MODDIR=${0%/*}

MOD_INTRO="Stop showing rotation suggestions button"
SEPARATE_LINE="----------------------------------------"

echo "$SEPARATE_LINE"
echo "- Rotation Suggestions Closed"
echo "- By Astoritin Ambrosius"
echo "$SEPARATE_LINE"
echo "- $MOD_INTRO"
echo "$SEPARATE_LINE"
result_rs="$(settings get secure show_rotation_suggestions)"
if [ $result_rs = 0 ]; then
    echo "- Current state: OFF"
    settings put secure show_rotation_suggestions 1
    echo "- Turn on suggestions button"
    echo "- Now button will be shown as detecting rotation"
elif [ $result_rs = 1 ]; then
    echo "- Current state: ON"
    settings put secure show_rotation_suggestions 0
    echo "- Turn off suggestions button"
    echo "- Now button will NOT be shown as detecting rotation"
fi
echo "$SEPARATE_LINE"
echo "- Case closed!"
sleep 1
exit 0