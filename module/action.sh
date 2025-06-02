#!/system/bin/sh
MODDIR=${0%/*}

echo "- Rotation Suggestions Closed"
echo " "
echo "- Stop showing rotation suggestions"
echo "- button as rotating screen"
echo " "
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
sleep 1
exit 0
