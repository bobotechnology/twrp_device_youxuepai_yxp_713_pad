# Contributing

Thanks for helping improve TWRP support for the Youxuepai U90.

## Before opening an issue

1. Confirm that the report is for yxp_713_pad and a build from this repository.
2. Reproduce from a clean Recovery boot when possible.
3. Include exact steps, the build identifier or commit, and a sanitized
   recovery log.
4. Do not include serial numbers, private partition contents, account data,
   encryption keys, or full proprietary firmware packages.

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for safe log collection.

## Pull request expectations

- Keep one logical change per pull request.
- Explain the hardware evidence behind board, fstab, input, USB, or kernel
  changes.
- Preserve stock artifacts separately from generated artifacts.
- Do not commit build outputs, local logs, editor state, or Python cache files.
- Run formatting and static checks before requesting review.

## Prebuilt kernel policy

The Recovery kernel is a deliberate exception to the usual source-only rule.
It is vendor-derived and required for this device to boot Recovery.

When changing it:

1. Start from the exact stock kernel accepted by
   tools/patch_himax_recovery_gate.py.
2. Keep each instruction patch documented and guarded by its expected original
   word.
3. Verify the uncompressed image changes only at approved offsets.
4. Preserve the FDT tail exactly.
5. Boot the resulting Recovery on hardware and validate display, touch, and
   ADB before merging.

## Suggested checks

~~~sh
git diff --check
python3 -c "from pathlib import Path; compile(Path('tools/patch_himax_recovery_gate.py').read_text(), 'tools/patch_himax_recovery_gate.py', 'exec')"
~~~

For a full build, follow [docs/BUILDING.md](docs/BUILDING.md).
