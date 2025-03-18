#!/system/bin/sh
SKIPUNZIP=1
VERIFY_DIR="$TMPDIR/.aa_verify"
MOD_NAME="$(grep_prop name "${TMPDIR}/module.prop")"
MOD_VER="$(grep_prop version "${TMPDIR}/module.prop") ($(grep_prop versionCode "${TMPDIR}/module.prop"))"

if [ "$API" -eq 29 ]; then
    logowl "Detect Android 10" "WARN"
    logowl "$MOD_NAME will NOT work as expect if developers"
    logowl "have NOT backported this feature into your ROM"
    logowl "Anyway, you may still have a try"

    if ! settings get secure show_rotation_suggestions &>/dev/null; then
        logowl "Detect this feature does NOT backport into your ROM" "ERROR"
        abort "Feature does NOT backport into ROM!"
    fi
fi

if [ "$API" -lt 29 ]; then
    logowl "Detect Android 9-" "ERROR"
    logowl "$MOD_NAME will NOT work"
    logowl "since this feature does NOT exist"
    abort "Android 9- is NOT support!"
fi

if [ ! -d "$VERIFY_DIR" ]; then
    mkdir -p "$VERIFY_DIR"
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
logowl "Essential checks"
extract "$ZIPFILE" 'aautilities.sh' "$VERIFY_DIR"
extract "$ZIPFILE" 'customize.sh' "$VERIFY_DIR"
logowl "Extract module files"
extract "$ZIPFILE" 'module.prop' "$MODPATH"
extract "$ZIPFILE" 'service.sh' "$MODPATH"
extract "$ZIPFILE" 'uninstall.sh' "$MODPATH"
rm -rf "$VERIFY_DIR"
set_module_files_perm
logowl "Welcome to use ${MOD_NAME}!"
