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
    sync
    sleep 3
done
