# Changelog

All notable changes to this device tree are recorded here.

## Unreleased

### Changed

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
