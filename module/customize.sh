#!/system/bin/sh
SKIPUNZIP=1
MODNAME=$(grep_prop name "${TMPDIR}/module.prop")

ui_print "- Extract aautilities.sh"
ui_print "- ZIPFILE: $ZIPFILE"
ui_print "- TMPDIR: $TMPDIR"
ui_print "- MODPATH: $MODPATH"
unzip -o "$ZIPFILE" 'aautilities.sh' -d "$TMPDIR" >&2
if [ ! -f "$TMPDIR/aautilities.sh" ]; then
  ui_print "! Failed to extract aautilities.sh!"
  abort "! This zip may be corrupted!"
fi

. "$TMPDIR/aautilities.sh"

module_install_proc(){
  ui_print "- Configuring $MODNAME"
  ui_print "- Extract module file(s)"
  extract "$ZIPFILE" 'module.prop'     "$MODPATH"
  extract "$ZIPFILE" 'service.sh' "$MODPATH"
  extract "$ZIPFILE" 'uninstall.sh' "$MODPATH"
}

show_system_info
enforce_install_from_magisk_app
module_install_proc
set_module_files_perm
ui_print "- Welcome to use ${MODNAME}!"
