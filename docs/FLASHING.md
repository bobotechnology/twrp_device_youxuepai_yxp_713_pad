# Flashing and first boot

## Read this first

- Use an unlocked device and a flashing workflow already known to work for
  your P713.
- Keep a matching stock Recovery image available for rollback.
- Verify the image came from this repository's workflow or from your own
  reproducible local build.
- The Recovery partition budget is 32 MiB. Do not flash an oversized image.

## Fastboot example

If Fastboot is already your known-good flashing path, a typical sequence is:

~~~sh
adb reboot bootloader
fastboot flash recovery recovery.img
fastboot reboot recovery
~~~

If your device uses another service tool or partition workflow, flash only the
Recovery image through that established path. Do not substitute boot, vbmeta,
or dynamic-partition images just to install this Recovery.

## First-boot checklist

Boot directly to Recovery after flashing and verify:

1. The TWRP UI renders without a black screen.
2. Himax touch works for taps and short swipes without any manual bootprof
   command or runtime patching.
3. USB ADB appears with adb devices.
4. The Recovery log has no kernel Oops, panic, watchdog, or repeated touch
   driver errors.

If any item fails, stop testing and collect logs before making more changes.
See [Troubleshooting](TROUBLESHOOTING.md).

## Rollback

Flash the previously saved matching stock Recovery image through the same
known-good method. Keep rollback images and test artifacts outside this Git
repository.
