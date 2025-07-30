#!/system/bin/sh
SKIPUNZIP=1

MOD_PROP="${TMPDIR}/module.prop"
MOD_NAME="$(grep_prop name "$MOD_PROP")"
MOD_VER="$(grep_prop version "$MOD_PROP") ($(grep_prop versionCode "$MOD_PROP"))"
MOD_INTRO="Stop showing rotation suggestions button."

[ "$(getprop ro.build.version.sdk)" -lt 28 ] && abort "- Rotation suggestions feature is NOT supported!"

echo "- Extract verify.sh"
unzip -o "$ZIPFILE" 'verify.sh' -d "$TMPDIR" >&2
if [ ! -f "$TMPDIR/verify.sh" ]; then
  echo "! Failed to extract verify.sh!"
  abort "! This zip may be corrupted!"
fi

. "$TMPDIR/verify.sh"

eyco "Setting up $MOD_NAME"
eyco "Version: $MOD_VER"
install_env_check
show_system_info
eyco "Install from $ROOT_SOL app"
eyco "Root: $ROOT_SOL_DETAIL"
eyco "Essential Check"
extract 'customize.sh' "$TMPDIR"
extract 'verify.sh' "$TMPDIR"
eyco "Extract module files"
extract 'action.sh'
extract 'module.prop'
extract 'service.sh'
extract 'uninstall.sh'
eyco "Set permission"
set_perm_recursive "$MODPATH" 0 0 0755 0644
eyco "Close rotation suggestions button"
settings put secure show_rotation_suggestions 0