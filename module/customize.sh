#!/system/bin/sh
SKIPUNZIP=1

VERIFY_DIR="$TMPDIR/.aa_verify"

MOD_NAME="$(grep_prop name "${TMPDIR}/module.prop")"
MOD_VER="$(grep_prop version "${TMPDIR}/module.prop") ($(grep_prop versionCode "${TMPDIR}/module.prop"))"
MOD_INTRO="A Magisk module to disable useless rotation suggestion button as rotating screen each time."

[ ! -d "$VERIFY_DIR" ] && mkdir -p "$VERIFY_DIR"

if ! settings get secure show_rotation_suggestions &>/dev/null; then
    abort "Your ROM does NOT support rotation suggestion feature"
fi

echo "- Extract aautilities.sh"
unzip -o "$ZIPFILE" 'aautilities.sh' -d "$TMPDIR" >&2
if [ ! -f "$TMPDIR/aautilities.sh" ]; then
  echo "! Failed to extract aautilities.sh!"
  abort "! This zip may be corrupted!"
fi

. "$TMPDIR/aautilities.sh"

logowl "Setting up $MOD_NAME"
logowl "Version: $MOD_VER"
install_env_check
show_system_info
logowl "Install from $ROOT_SOL app"
logowl "Essential checks"
extract "$ZIPFILE" 'aautilities.sh' "$VERIFY_DIR"
extract "$ZIPFILE" 'customize.sh' "$VERIFY_DIR"
logowl "Extract module files"
extract "$ZIPFILE" 'module.prop' "$MODPATH"
extract "$ZIPFILE" 'action.sh' "$MODPATH"
extract "$ZIPFILE" 'service.sh' "$MODPATH"
extract "$ZIPFILE" 'uninstall.sh' "$MODPATH"
logowl "Set permission"
set_permission_recursive "$MODPATH" 0 0 0755 0644
logowl "Welcome to use ${MOD_NAME}!"
DESCRIPTION="[⏳Reboot to take effect.] $MOD_INTRO"
update_config_value "description" "$DESCRIPTION" "$MODPATH/module.prop"
