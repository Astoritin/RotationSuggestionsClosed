if ! command -v abort >/dev/null 2>&1; then
    logowl "Detect abort does NOT available!" "WARN"
    abort() {
        echo "[!] $1"
        exit 1
    }
fi

is_kernelsu() {
    if [ -n "$KSU" ]; then
        logowl "Install from KernelSU"
        logowl "KernelSU version: $KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
        ROOT_SOL="KernelSU (kernel:$KSU_KERNEL_VER_CODE, ksud:$KSU_VER_CODE)"
        if [ -n "$(which magisk)" ]; then
            logowl "Detect multiple Root implements!" "WARN"
            ROOT_SOL="Multiple"
        fi
        return 0
    fi
    return 1
}

is_apatch() {
    if [ -n "$APATCH" ]; then
        logowl "Install from APatch"
        logowl "APatch version: $APATCH_VER_CODE"
        ROOT_SOL="APatch ($APATCH_VER_CODE)"
        return 0
    fi
    return 1
}

is_magisk() {
    if [ -n "$MAGISK_VER_CODE" ] || [ -n "$(magisk -v || magisk -V)" ]; then
        MAGISK_V_VER_NAME="$(magisk -v)"
        MAGISK_V_VER_CODE="$(magisk -V)"
        case "$MAGISK_VER $MAGISK_V_VER_NAME" in
            *"-alpha"*) MAGISK_BRANCH_NAME="Magisk Alpha" ;;
            *"-lite"*)  MAGISK_BRANCH_NAME="Magisk Lite" ;;
            *"-kitsune"*) MAGISK_BRANCH_NAME="Kitsune Mask" ;;
            *"-delta"*) MAGISK_BRANCH_NAME="Magisk Delta" ;;
            *) MAGISK_BRANCH_NAME="Magisk" ;;
        esac
        ROOT_SOL="$MAGISK_BRANCH_NAME (${MAGISK_VER_CODE:-$MAGISK_V_VER_CODE})"
        logowl "Installing from $ROOT_SOL"
        return 0
    fi
    return 1
}

is_recovery() {
    ROOT_SOL="Recovery"
    logowl "Install module in Recovery mode is not supported, especially for KernelSU / APatch!" "FATAL"
    logowl "Please install this module in Magisk / KernelSU / APatch APP!" "FATAL"
    abort
}

install_env_check() {
    # install_env_check: a function to check the current root solution
    # Magisk branch name is Official by default
    # Root solution is Magisk by default

    MAGISK_BRANCH_NAME="Official"
    ROOT_SOL="Magisk"

    if ! is_kernelsu && ! is_apatch && ! is_magisk; then
        is_recovery
    fi
}


module_intro() {
    # module_intro: a function to show module basic info

    MODULE_PROP="${MODDIR}/module.prop"
    MOD_NAME="$(sed -n 's/^name=\(.*\)/\1/p' "$MODULE_PROP")"
    MOD_AUTHOR="$(sed -n 's/^author=\(.*\)/\1/p' "$MODULE_PROP")"
    MOD_VER="$(sed -n 's/^version=\(.*\)/\1/p' "$MODULE_PROP") ($(sed -n 's/^versionCode=\(.*\)/\1/p' "$MODULE_PROP"))"

    install_env_check
    print_line

    logowl "$MOD_NAME"
    logowl "By $MOD_AUTHOR"
    logowl "Version: $MOD_VER"
    logowl "Root solution: $ROOT_SOL"
    logowl "Current time stamp: $(date +"%Y-%m-%d %H:%M:%S")"
    print_line
}

logowl() {
    # logowl: a function to format the log output
    # LOG_MSG: the log message you need to print
    # LOG_LEVEL: the level of this log message
    LOG_MSG="$1"
    LOG_LEVEL="${2:-DEF}"

    if [ -z "$LOG_MSG" ]; then
        echo "! LOG_MSG is not provided yet!"
        return 1
    fi

    case "$LOG_LEVEL" in
        "TIPS") LOG_LEVEL="*" ;;
        "WARN") LOG_LEVEL="- Warn:" ;;
        "ERROR") LOG_LEVEL="! ERROR:" ;;
        "FATAL") LOG_LEVEL="× FATAL:" ;;
        "NONE") LOG_LEVEL=" " ;;
        *) LOG_LEVEL="-" ;;
    esac

    if [ -z "$LOG_FILE" ]; then
        if command -v ui_print >/dev/null 2>&1 && [ "$BOOTMODE" ]; then
            ui_print "$LOG_LEVEL $LOG_MSG" 2>/dev/null
        else
            echo "$LOG_LEVEL $LOG_MSG"
        fi
    else
        if [ "$LOG_LEVEL" = "! ERROR:" ] || [ "$LOG_LEVEL" = "× FATAL:" ]; then
            print_line >> "$LOG_FILE"
        fi
        echo "$LOG_LEVEL $LOG_MSG" >> "$LOG_FILE"
        if [ "$LOG_LEVEL" = "! ERROR:" ] || [ "$LOG_LEVEL" = "× FATAL:" ]; then
            print_line >> "$LOG_FILE"
        fi
    fi
}

print_line() {
    # print_line: a function to print separate line
    length=${1:-50}
    line=$(printf "%-${length}s" | tr ' ' '-')
    echo "$line"
}

show_system_info() {
    # show_system_info: to show the Device, Android and RAM info.

    logowl "Device: $(getprop ro.product.brand) $(getprop ro.product.model) ($(getprop ro.product.device))"
    logowl "OS: Android $(getprop ro.build.version.release) (API $(getprop ro.build.version.sdk)), $(getprop ro.product.cpu.abi | cut -d '-' -f1)"
    mem_info=$(free -m)
    ram_total=$(echo "$mem_info" | awk '/Mem/ {print $2}')
    ram_used=$(echo "$mem_info" | awk '/Mem/ {print $3}')
    ram_free=$((ram_total - ram_used))
    swap_total=$(echo "$mem_info" | awk '/Swap/ {print $2}')
    swap_used=$(echo "$mem_info" | awk '/Swap/ {print $3}')
    swap_free=$(echo "$mem_info" | awk '/Swap/ {print $4}')
    logowl "RAM: ${ram_total}MB  Used:${ram_used}MB  Free:${ram_free}MB"
    logowl "SWAP: ${swap_total}MB  Used:${swap_used}MB  Free:${swap_free}MB"
}

abort_verify() {
    # abort_verify: a function to abort verify because of detecting hash does NOT match

    rm -rf "$VERIFY_DIR"
    print_line
    logowl "$1" "WARN"
    logowl "This zip may be corrupted or have been maliciously modified!" "WARN"
    logowl "Please try to download again or get it from official source!" "WARN"
    abort "**************************************************"
}

extract() {
    # extract: a function to extract zip and verify the hash
    # zip: the path of zip file
    # file: the filename you want to extract from zip file
    # dir: the dir you want to extract to
    #
    # junk_paths: whether preserve the file's folders in zip file or not
    # For example, a file in zip file is: /META/AA/config.ini
    # if false, file config.ini will be extracted into /(target dir)/META/AA/config.ini
    # if true, file config.ini will be extracted into /(target dir)/config.ini

    zip=$1
    file=$2
    dir=$3
    junk_paths=${4:-false}
    opts="-o"
    [ $junk_paths = true ] && opts="-oj"

    file_path=""
    hash_path=""
    if [ $junk_paths = true ]; then
      file_path="$dir/$(basename "$file")"
      hash_path="$VERIFY_DIR/$(basename "$file").sha256"
    else
      file_path="$dir/$file"
      hash_path="$VERIFY_DIR/$file.sha256"
    fi

    unzip $opts "$zip" "$file" -d "$dir" >&2
    [ -f "$file_path" ] || abort_verify "$file does NOT exist!"
    logowl "Extract $file -> $file_path" >&1

    unzip $opts "$zip" "$file.sha256" -d "$VERIFY_DIR" >&2
    [ -f "$hash_path" ] || abort_verify "$file.sha256 does NOT exist!"

    expected_hash="$(cat "$hash_path")"
    calculated_hash="$(sha256sum "$file_path" | cut -d ' ' -f1)"

    if [ "$expected_hash" == "$calculated_hash" ]; then
      logowl "Verified $file" >&1
    else
      abort_verify "Failed to verify $file"
      rm -rf "$VERIFY_DIR"
    fi
}

set_module_files_perm() {
    # set_module_files_perm: set module files's permission
    # only use in installing module

    logowl "Setting permissions"
    set_perm_recursive "$MODPATH" 0 0 0755 0644
}
