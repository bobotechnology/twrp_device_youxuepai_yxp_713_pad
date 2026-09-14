# TWRP Device Tree for Youxuepai P713

[![Build TWRP](https://github.com/bobotechnology/twrp_device_youxuepai_yxp_713_pad/actions/workflows/build.yml/badge.svg)](https://github.com/bobotechnology/twrp_device_youxuepai_yxp_713_pad/actions/workflows/build.yml)
[![Device](https://img.shields.io/badge/device-Youxuepai%20P713-1f6feb)](https://github.com/bobotechnology/twrp_device_youxuepai_yxp_713_pad)
[![Platform](https://img.shields.io/badge/platform-MediaTek%20MT6779-6f42c1)](https://github.com/bobotechnology/twrp_device_youxuepai_yxp_713_pad)

An unofficial TWRP 12.1 device tree for the **Youxuepai P713** tablet
(codename: **yxp_713_pad**, platform: **MediaTek MT6779**).

中文简介：这是优学派 P713 的 TWRP 设备树。Recovery 的显示、Himax 触摸和 USB ADB
已经在真机 Recovery 环境中验证；请先阅读刷写说明，再对自己的设备负责。

> [!WARNING]
> This project targets one specific device and firmware family. Unlocking,
> flashing, formatting, or modifying partitions can make a device unbootable
> and may erase data. Keep a known-good stock recovery image and use only the
> flashing path that already works for your device.

## Device snapshot

| Property | Value |
| --- | --- |
| Device | Youxuepai P713 |
| Codename | yxp_713_pad |
| SoC | MediaTek MT6779 |
| Architecture | arm64 / arm64-v8a |
| Kernel | Linux 4.9.190, vendor prebuilt |
| TWRP base | twrp-12.1 |
| Boot image header | v2 |
| Recovery partition budget | 32 MiB |

## Current status

Hardware verification below was completed on **September 14, 2026** using this device tree's Recovery build.

| Component | Status | Notes |
| --- | --- | --- |
| Recovery boot | Verified | Tested on hardware |
| Display | Verified | Recovery UI renders correctly |
| Himax touchscreen | Verified | Input reaches the TWRP input stack |
| USB ADB | Verified | Recovery ConfigFS path |
| MTP | Not validated | ADB is the supported USB transport for now |
| Encryption / decryption | Not validated | Reports with logs are welcome |
| Backup / restore | Not validated | Reports with logs are welcome |

## What makes this tree different

- Uses the device's vendor kernel, DTB, and DTBO instead of a generic MT6779
  kernel.
- Keeps the real Himax touchscreen as the active TWRP input source and
  blacklists the non-reporting mtk-tpd compatibility node.
- Retains a small, documented Recovery-only kernel patch set. It enables the
  vendor Himax driver in recovery and removes its Android boot-animation gate,
  which otherwise drops every touch report before it reaches input.
- Configures the device's ConfigFS USB gadget path for dependable Recovery ADB.

## Downloads

Build artifacts are uploaded by GitHub Actions. Open the latest successful
[Build TWRP workflow run](https://github.com/bobotechnology/twrp_device_youxuepai_yxp_713_pad/actions/workflows/build.yml), then download the
recovery artifact from that run.

Before flashing, verify the artifact origin and checksum yourself. Never flash
an image copied from an untrusted mirror.

## Documentation

- [Build from source](docs/BUILDING.md)
- [Flash and first-boot checklist](docs/FLASHING.md)
- [Troubleshooting and logs](docs/TROUBLESHOOTING.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)
- [Security policy](SECURITY.md)

## Kernel provenance and patch policy

The files under prebuilt are vendor-derived boot artifacts for this exact
device. The Recovery kernel is intentionally generated from the matching stock
kernel with a tightly scoped patch script in tools.

The patch tool refuses an unexpected stock input hash, verifies every source
instruction before replacing it, checks the exact modified byte footprint, and
preserves the FDT tail. Do not replace these artifacts with blobs from another
P713 revision or another MT6779 device without re-validating the entire boot
and input path.

## Support and contributions

Please open an issue with a clear build identifier, reproduction steps, and a
sanitized recovery log. Do not publish serial numbers, personal data, account
tokens, decrypted userdata contents, or proprietary firmware dumps.

Small, reviewable pull requests are preferred. Read
[CONTRIBUTING.md](CONTRIBUTING.md) before changing board configuration, fstab
entries, or prebuilt boot artifacts.

## License and vendor material

Source files retain their existing license headers. Vendor-derived binary
artifacts remain subject to their original provenance and applicable vendor
terms; this repository does not grant rights beyond those terms.
