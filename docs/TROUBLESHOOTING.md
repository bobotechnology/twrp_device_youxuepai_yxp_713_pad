# Troubleshooting

## Recovery does not boot

1. Verify that the image is for yxp_713_pad and was built from this tree.
2. Confirm that the boot image header, DTB, DTBO, and partition budget match
   the device configuration.
3. Reflash the known-good stock Recovery image if the device cannot re-enter
   Recovery safely.

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
