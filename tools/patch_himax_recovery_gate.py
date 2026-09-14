#!/usr/bin/env python3
"""Create a recovery kernel that permits the active Himax driver in recovery.

The original P713 MT6779 kernel is a gzip-compressed ARM64 Image followed by
an FDT payload. This utility preserves that FDT tail exactly and changes only
the two conditional branches which reject boot modes 1 and 2 in the HXTP
tpd_driver_init routine.
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
from pathlib import Path
import struct
import zlib


EXPECTED_ORIGINAL_SHA256 = "4cf07e13d26ae95c197fa4f280d94aed9a341344d4b441f5eea3462bf82d8b3b"
PATCHES = {
    0x68BB5C: (0x54000080, 0xD503201F),  # b.eq recovery block -> nop
    0x68BB68: (0x54000081, 0x14000004),  # b.ne recovery block -> b normal path
}


def inflate_single_gzip_member(data: bytes) -> tuple[bytes, bytes]:
    stream = zlib.decompressobj(16 + zlib.MAX_WBITS)
    image = stream.decompress(data) + stream.flush()
    if not stream.eof:
        raise ValueError("kernel gzip member did not terminate cleanly")
    return image, stream.unused_data


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="original prebuilt kernel")
    parser.add_argument("output", type=Path, help="patched kernel output path")
    args = parser.parse_args()

    source = args.input.read_bytes()
    source_hash = hashlib.sha256(source).hexdigest()
    if source_hash != EXPECTED_ORIGINAL_SHA256:
        raise SystemExit(
            "unexpected input SHA-256: "
            f"{source_hash}; expected {EXPECTED_ORIGINAL_SHA256}"
        )

    image, fdt_tail = inflate_single_gzip_member(source)
    patched = bytearray(image)
    for offset, (expected, replacement) in PATCHES.items():
        actual = struct.unpack_from("<I", patched, offset)[0]
        if actual != expected:
            raise SystemExit(
                f"unexpected instruction at {offset:#x}: "
                f"{actual:#010x}; expected {expected:#010x}"
            )
        struct.pack_into("<I", patched, offset, replacement)

    output = gzip.compress(bytes(patched), compresslevel=9, mtime=0) + fdt_tail
    round_trip, round_trip_tail = inflate_single_gzip_member(output)
    if round_trip != patched or round_trip_tail != fdt_tail:
        raise SystemExit("patched kernel round-trip verification failed")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(output)
    print(f"input SHA-256:  {source_hash}")
    print(f"output SHA-256: {hashlib.sha256(output).hexdigest()}")
    print(f"FDT tail SHA-256: {hashlib.sha256(fdt_tail).hexdigest()}")


if __name__ == "__main__":
    main()
