#!/system/bin/sh

TMP=/tmp/yxp_713_pad-input-debug
mkdir -p "$TMP"

# The service starts before TWRP/vold has necessarily mounted storage.
# Capture the early kernel ring buffer in tmpfs, then copy it to a removable
# volume as soon as one is mounted. A pre-inserted FAT32 microSD card is the
# preferred collection medium; USB OTG and already-mounted shared storage
# are supported as fallbacks.
/system/bin/dmesg > "$TMP/twrp-dmesg-boot.log" 2>&1

is_mounted() {
    grep -q "[[:space:]]$1[[:space:]]" /proc/mounts
}

pick_output_dir() {
    for mountpoint in \
        /external_sd \
        /sdcard1 \
        /mnt/media_rw/sdcard1 \
        /usb_otg \
        /mnt/media_rw/usbotg; do
        if [ -d "$mountpoint" ] && is_mounted "$mountpoint"; then
            echo "$mountpoint/TWRP/yxp_713_pad-input-debug"
            return 0
        fi
    done

    # Do not force-mount /data: it may be encrypted. Use it only when TWRP
    # has already mounted public shared storage successfully.
    if [ -d /data/media/0 ] && is_mounted /data; then
        echo "/data/media/0/TWRP/yxp_713_pad-input-debug"
        return 0
    fi
    if [ -d /sdcard ] && is_mounted /sdcard; then
        echo "/sdcard/TWRP/yxp_713_pad-input-debug"
        return 0
    fi
    return 1
}

capture_logcat() {
    if [ -x /system/bin/logcat ]; then
        /system/bin/logcat -b all -d -v threadtime > "$1" 2>&1
    else
        echo "logcat is unavailable in this recovery ramdisk" > "$1"
    fi
}

capture_usb_state() {
    {
        echo "=== timestamp ==="
        date
        echo "=== USB and ADB properties ==="
        getprop | grep -E '^\[(init\.svc\.adbd|init\.svc_debug_pid\.adbd|service\.adb\.root|sys\.usb|persist\.sys\.usb|ro\.adb|ro\.debuggable)'
        echo "=== FunctionFS and ConfigFS mounts ==="
        grep -E '[[:space:]](functionfs|configfs)[[:space:]]' /proc/mounts
        echo "=== android_usb attributes ==="
        for node in \
            /sys/class/android_usb/android0/enable \
            /sys/class/android_usb/android0/functions \
            /sys/class/android_usb/android0/state \
            /sys/class/android_usb/android0/idVendor \
            /sys/class/android_usb/android0/idProduct; do
            [ -e "$node" ] || continue
            printf '%s: ' "$node"
            cat "$node" 2>/dev/null
        done
        echo "=== UDC state ==="
        for udc in /sys/class/udc/*; do
            [ -d "$udc" ] || continue
            echo "-- $udc --"
            for node in "$udc"/state "$udc"/function "$udc"/soft_connect \
                "$udc"/device/mode "$udc"/device/cmode "$udc"/device/role; do
                [ -e "$node" ] || continue
                printf '%s: ' "$node"
                cat "$node" 2>/dev/null
            done
        done
        echo "=== FunctionFS endpoints ==="
        ls -la /dev/usb-ffs /dev/usb-ffs/adb
        echo "=== ConfigFS gadget tree ==="
        ls -laR /config/usb_gadget/g1 2>/dev/null
        echo "=== current adbd process ==="
        pid="$(getprop init.svc_debug_pid.adbd)"
        echo "init.svc_debug_pid.adbd=$pid"
        case "$pid" in
            ''|*[!0-9]*) ;;
            *)
                if [ -d "/proc/$pid" ]; then
                    cat "/proc/$pid/status"
                    echo "wchan=$(cat "/proc/$pid/wchan" 2>/dev/null)"
                fi
                ;;
        esac
        echo "=== process table ==="
        ps -A
    } > "$OUT/twrp-usb-state.log" 2>&1
}

OUT=
while [ -z "$OUT" ]; do
    candidate="$(pick_output_dir 2>/dev/null)"
    if [ -n "$candidate" ] && mkdir -p "$candidate" 2>/dev/null && \
            touch "$candidate/.twrp-write-test" 2>/dev/null; then
        rm -f "$candidate/.twrp-write-test"
        OUT="$candidate"
    else
        sleep 2
    fi
done

cp "$TMP/twrp-dmesg-boot.log" "$OUT/" 2>/dev/null
echo "destination=$OUT" > "$OUT/twrp-diagnostic-destination.txt"
capture_usb_state
capture_logcat "$OUT/twrp-logcat-boot.log"

{
    echo "=== boot properties ==="
    getprop
    echo "=== input devices ==="
    cat /proc/bus/input/devices
    echo "=== getevent capabilities ==="
    /system/bin/getevent -pl
    echo "=== device nodes ==="
    ls -la /dev/input
    echo "=== relevant sysfs ==="
    for node in /sys/class/input/event*/device/name; do
        echo "$node: $(cat "$node" 2>/dev/null)"
    done
} > "$OUT/twrp-input-info.log" 2>&1

HIMAX_DEV=
MTK_TPD_DEV=
for node in /sys/class/input/event*/device/name; do
    event="$(basename "$(dirname "$(dirname "$node")")")"
    name="$(cat "$node" 2>/dev/null)"
    case "$name" in
        himax-touchscreen) HIMAX_DEV="/dev/input/$event" ;;
        mtk-tpd) MTK_TPD_DEV="/dev/input/$event" ;;
    esac
done

echo "himax=$HIMAX_DEV mtk-tpd=$MTK_TPD_DEV" > "$OUT/twrp-input-map.log"

[ -n "$HIMAX_DEV" ] && /system/bin/getevent -lt "$HIMAX_DEV" > "$OUT/twrp-himax-events.log" 2>&1 &
[ -n "$MTK_TPD_DEV" ] && /system/bin/getevent -lt "$MTK_TPD_DEV" > "$OUT/twrp-mtk-tpd-events.log" 2>&1 &

while true; do
    /system/bin/dmesg > "$OUT/twrp-dmesg-latest.log" 2>&1
    capture_usb_state
    capture_logcat "$OUT/twrp-logcat-latest.log"
    sync
    sleep 3
done
