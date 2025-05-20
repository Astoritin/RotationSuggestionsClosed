#!/system/bin/sh
MODDIR=${0%/*}

result_rs="$(settings get secure show_rotation_suggestions)"
echo "- Current result of showing"
echo "- rotation suggestion button: $result_rs"
if [ $result_rs = 0 ]; then
    echo "- Current state: disabled"
    settings put secure show_rotation_suggestions 1
elif [ $result_rs = 1 ]; then
    echo "- Current state: enabled"
    settings put secure show_rotation_suggestions 0
fi
echo "- Done"
