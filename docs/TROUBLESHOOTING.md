# Troubleshooting

## Recovery does not boot

1. Verify that the image is for yxp_713_pad and was built from this tree.
2. Confirm that the boot image header, DTB, DTBO, and partition budget match
   the device configuration.
3. Reflash the known-good stock Recovery image if the device cannot re-enter
   Recovery safely.

## Stock Recovery returns after booting Android

This firmware includes a stock `install-recovery.sh` service. It checks the
Recovery partition during normal Android startup and can restore the stock
Recovery image when TWRP is present. This is expected on the stock system.

For a system installation workflow, do not boot the stock Android system
between flashing TWRP and installing the replacement system. If Android was
already booted, flash TWRP again before entering Recovery.

## Vendor or data mount messages

The device uses read-only logical `system`, `vendor`, and `product`
partitions. Current builds mount them with `ro,noload` to avoid journal replay
and the vendor-kernel mount rejection seen with a read-write attempt.

`/data` also contains emulated internal storage at `/data/media`. The device
tree declares this explicitly and disables MTP because this kernel's ConfigFS
gadget path is validated for ADB only. A stale log from an older build may
still show `MTP Enabled`; verify the TWRP version and collect a fresh
`/tmp/recovery.log`.

## Touch does not respond

The real touch source is the Himax input device. The mtk-tpd compatibility
node is intentionally blacklisted because it does not provide the working
touch stream on this device.

With ADB available, identify the event node by name:

~~~sh
adb shell getevent -il
adb shell cat /sys/class/input/event*/device/name
~~~

Then capture a short direct trace from the node whose name is
himax-touchscreen:

~~~sh
adb shell getevent -lt /dev/input/eventX
~~~

Replace eventX with the actual Himax event node. A healthy trace contains
BTN_TOUCH, ABS_MT_POSITION_X, ABS_MT_POSITION_Y, and SYN_REPORT events.

## ADB is unavailable

1. Reconnect the cable after Recovery finishes booting.
2. Run adb devices on the host.
3. Try another known-good USB cable or port.
4. Collect the Recovery log after ADB returns.

This tree currently treats ADB as the supported Recovery USB transport. MTP is
not yet marked as validated.

## Safe log collection

Use temporary storage and pull logs over ADB. Do not write diagnostics to
cache, and do not commit logs to the repository.

~~~sh
adb pull /tmp/recovery.log recovery.log
adb shell dmesg > dmesg.txt
~~~

Before sharing logs, remove serial numbers, paths containing personal data,
tokens, and decrypted userdata details.

## Reporting a regression

Include:

- Device and exact build commit
- Whether the problem reproduces from a clean Recovery boot
- Steps to reproduce
- Expected and actual behavior
- Sanitized recovery.log and relevant dmesg lines
