#!/system/bin/sh
MODDIR=${0%/*}

settings put secure show_rotation_suggestions 1
settings put secure num_rotation_suggestions_accepted 0