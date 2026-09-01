#!/system/bin/sh

OUT=/cache/recovery
mkdir -p "$OUT"

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

/system/bin/dmesg > "$OUT/twrp-dmesg-boot.log" 2>&1

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
