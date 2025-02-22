#!/system/bin/sh
SKIPUNZIP=false
MODNAME=$(grep_prop name "${TMPDIR}/module.prop")

enforce_install_from_magisk_app(){
  if [ "$BOOTMODE" ] && [ "$KSU" ]; then
  ui_print "- Install from KernelSU APP"
  ui_print "- KernelSU version: $KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
  if [ "$(which magisk)" ]; then
    ui_print "- Detect multiple Root implements!"
  fi
  elif [ "$BOOTMODE" ] && [ "$APATCH" ]; then
  ui_print "- Install from APatch APP"
  ui_print "- APatch version: $APATCH_VER_CODE"
  elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
    if [[ "$MAGISK_VER" == *"-alpha" ]]; then
    ui_print "- Install from Magisk Alpha APP"
    elif [[ "$MAGISK_VER" == *"-lite" ]]; then
    ui_print "- Install from Magisk Lite APP"
    elif [[ "$MAGISK_VER" == *"-kitsune" ]]; then
    ui_print "- Install from Kitsune Mask APP"
    elif [[ "$MAGISK_VER" == *"-delta" ]]; then
    ui_print "- Install from Magisk Delta APP"
    else
    ui_print "- Install from Magisk APP"
    fi
  ui_print "- Magisk version name: $MAGISK_VER"
  ui_print "- Magisk version code: $MAGISK_VER_CODE"
  else
  ui_print "! Install modules in Recovery mode is not support!"
  about "! Please install this module in Magisk/KernelSU/APatch APP!"
  fi
}

set_module_files_perm(){
  ui_print "- Setting permissions"
  set_perm_recursive "$MODPATH" 0 0 0755 0644
}

show_system_info(){
  ui_print "- Device brand: `getprop ro.product.brand`"
  ui_print "- Device model: `getprop ro.product.model`"
  ui_print "- Device codeName: `getprop ro.product.device`"
  ui_print "- Device Architecture: $ARCH"
  ui_print "- Android version: `getprop ro.build.version.release` API $API"
  ui_print "- RAM space: `free -m|grep "Mem"|awk '{print $2}'`MB  used:`free -m|grep "Mem"|awk '{print $3}'`MB  free:$((`free -m|grep "Mem"|awk '{print $2}'`-`free -m|grep "Mem"|awk '{print $3}'`))MB"
  ui_print "- SWAP space: `free -m|grep "Swap"|awk '{print $2}'`MB  used:`free -m|grep "Swap"|awk '{print $3}'`MB  free:`free -m|grep "Swap"|awk '{print $4}'`MB"
}

REPLACE="
"

show_system_info
enforce_install_from_magisk_app
# set_module_files_perm
ui_print "- Welcome to use ${MODNAME}!"
