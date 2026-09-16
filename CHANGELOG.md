# Changelog

All notable changes to this device tree are recorded here.

## Unreleased

### Changed

- Corrected the public device identity and Recovery product model to
  Youxuepai U90; `yxp_713_pad` remains the technical codename.
- Matched the super partition and dynamic partition group sizes to the
  November 29, 2022 stock firmware layout.
- Defaulted Recovery to Simplified Chinese, disabled unsupported MTP, made the
  data-media layout explicit, and prevented screen blanking from suspending
  the Himax touch controller.
- Mounted logical system, vendor, and product read-only with `noload`, and
  corrected removable-storage fstab entries.
- Added a tag-driven and manually dispatchable GitHub Release workflow that
  builds, verifies, names, and publishes the Recovery image with SHA-256.
- Removed the one-shot runtime input/USB diagnostic service from production
  Recovery images after hardware validation completed.
- Added repository hygiene, contributor guidance, issue forms, and build
  documentation.

## 2026-09-14

### Fixed

- Restored Himax touch input in Recovery by bypassing the vendor
  boot-animation-completion return in himax_ts_work.
- Kept the Himax driver active during Recovery boot and retained the correct
  mtk-tpd blacklist.
- Enabled a reliable ConfigFS ADB path for Recovery.

### Added

- Added a reproducible, hash-pinned kernel patch utility for the Recovery
  prebuilt.
