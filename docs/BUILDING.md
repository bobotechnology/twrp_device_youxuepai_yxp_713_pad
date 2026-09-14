# Building TWRP

The GitHub Actions workflow is the reference build environment. It uses Ubuntu
22.04 and the TWRP 12.1 minimal manifest. Local builds should follow the same
branch and product configuration.

## Prerequisites

- A Linux host with a current Python 3, Git, Java 11, and the Android/TWRP
  build dependencies.
- The Android repo tool.
- Enough disk space for a TWRP source checkout and build output.

## Local build

~~~sh
mkdir -p twrp-p713 && cd twrp-p713
repo init --depth=1 \
  -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git \
  -b twrp-12.1
repo sync -c --no-tags -j$(nproc)

mkdir -p device/youxuepai
git clone https://github.com/bobotechnology/twrp_device_youxuepai_yxp_713_pad.git \
  device/youxuepai/yxp_713_pad

source build/envsetup.sh
lunch twrp_yxp_713_pad-eng
mka recoveryimage -j$(nproc)
~~~

The output image is expected at:

~~~text
out/target/product/yxp_713_pad/recovery.img
~~~

## Prebuilt kernel contract

This tree intentionally uses a vendor prebuilt kernel, DTB, and DTBO. Do not
replace them with a generic MT6779 image.

The Recovery kernel patch utility requires the exact matching stock compressed
kernel. It checks the input SHA-256 before making any change.

~~~sh
python3 tools/patch_himax_recovery_gate.py \
  /path/to/matching-stock-kernel \
  /tmp/yxp_713_pad-recovery-kernel
~~~

Review the resulting hash and byte-level validation before replacing
prebuilt/kernel. The script is intentionally not an automatic build hook:
updating a vendor binary is a reviewable, hardware-validated operation.

## Pre-flight checks

~~~sh
git diff --check
python3 -c "from pathlib import Path; compile(Path('tools/patch_himax_recovery_gate.py').read_text(), 'tools/patch_himax_recovery_gate.py', 'exec')"
~~~

After a successful build, confirm that recovery.img is no larger than the
32 MiB Recovery partition budget before flashing it.
