# Publishing a release

The release workflow is deliberately separate from ordinary pull-request and
main-branch builds. A published image must be traceable to one immutable tag
and one successful Recovery build.

## What the workflow does

`.github/workflows/release.yml` calls the same reusable build workflow used by
CI. Before creating a GitHub Release, it verifies the generated checksum,
repackages the asset with a device-specific name, and attaches both files:

- `twrp-u90-recovery.img`
- `twrp-u90-recovery.img.sha256`

The release notes record that the image targets the **Youxuepai U90**
(`yxp_713_pad`, MediaTek MT6779). The workflow never publishes a build that
exceeds the 32 MiB Recovery partition budget.

## Tag-triggered release

Create an annotated tag from the reviewed `main` commit and push it. Tags must
start with `u90-twrp-`.

~~~sh
git switch main
git pull --ff-only origin main
git tag -a u90-twrp-2026.09.14-r1 -m "TWRP for Youxuepai U90"
git push origin u90-twrp-2026.09.14-r1
~~~

The tag starts the release workflow, which rebuilds the image and publishes the
GitHub Release only after build and checksum verification succeed.

## Manual release

From the **Publish TWRP Release** workflow page, choose **Run workflow** and
provide a new tag in the same `u90-twrp-*` format. The workflow creates that
tag at the selected workflow ref after its build passes. Run it from reviewed
`main`. Use the prerelease option for release candidates or experimental test
builds.

## Before publishing

1. Confirm that the candidate booted in Recovery on a Youxuepai U90.
2. Verify display, Himax touch, and USB ADB.
3. Confirm rollback material is available.
4. Use a new immutable tag; do not overwrite an existing release to change the
   source commit.
5. Download the published files and validate the attached SHA-256 checksum.

For flashing instructions, see [Flash and first boot](FLASHING.md).
