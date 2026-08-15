#!/usr/bin/env python3
"""Fail if any 64-bit .so in an Android App Bundle has PT_LOAD align < 16 KiB.

Play Console reports this as "Memory page size: Does not support 16 KB".
Apps targeting API 35+ must ship 16 KB-aligned native libs (Nov 2025+).
"""
from __future__ import annotations

import argparse
import struct
import sys
import zipfile
from io import BytesIO
from pathlib import Path

ALIGN_16KB = 16384
PT_LOAD = 1
ELF_MAGIC = b"\x7fELF"
ELFCLASS64 = 2
ELFDATA2LSB = 1
SO_PREFIXES = (
    "lib/arm64-v8a/",
    "lib/x86_64/",
    "/lib/arm64-v8a/",
    "/lib/x86_64/",
)


def _is_64bit_so_path(name: str) -> bool:
    normalized = name.replace("\\", "/")
    return normalized.endswith(".so") and any(p in normalized for p in SO_PREFIXES)


def min_pt_load_align(elf: bytes) -> int | None:
    """Return the smallest PT_LOAD p_align, or None if not a 64-bit LE ELF."""
    if len(elf) < 64 or elf[:4] != ELF_MAGIC:
        return None
    if elf[4] != ELFCLASS64 or elf[5] != ELFDATA2LSB:
        return None
    phoff = struct.unpack_from("<Q", elf, 32)[0]
    phentsize = struct.unpack_from("<H", elf, 54)[0]
    phnum = struct.unpack_from("<H", elf, 56)[0]
    if phentsize < 56 or phnum == 0:
        return None
    aligns: list[int] = []
    for i in range(phnum):
        off = phoff + i * phentsize
        if off + 56 > len(elf):
            break
        p_type = struct.unpack_from("<I", elf, off)[0]
        if p_type != PT_LOAD:
            continue
        aligns.append(struct.unpack_from("<Q", elf, off + 48)[0])
    if not aligns:
        return None
    return min(aligns)


def _scan_zip(zf: zipfile.ZipFile, prefix: str = "") -> list[tuple[str, int]]:
    bad: list[tuple[str, int]] = []
    for name in zf.namelist():
        label = f"{prefix}{name}" if not prefix else f"{prefix}!{name}"
        if _is_64bit_so_path(name):
            align = min_pt_load_align(zf.read(name))
            if align is not None and align < ALIGN_16KB:
                bad.append((label, align))
    return bad


def find_unaligned_libs(aab_path: Path) -> list[tuple[str, int]]:
    bad: list[tuple[str, int]] = []
    with zipfile.ZipFile(aab_path) as bundle:
        bad.extend(_scan_zip(bundle))
        for nested in bundle.namelist():
            if not nested.endswith(".zip"):
                continue
            try:
                module = zipfile.ZipFile(BytesIO(bundle.read(nested)))
            except zipfile.BadZipFile:
                continue
            with module:
                bad.extend(_scan_zip(module, prefix=nested))
    return bad


def check_aab(aab_path: Path) -> int:
    if not aab_path.is_file():
        print(f"AAB not found: {aab_path}", file=sys.stderr)
        return 1
    bad = find_unaligned_libs(aab_path)
    if not bad:
        print(f"16 KB ELF alignment OK: {aab_path}")
        return 0
    print("16 KB ELF alignment FAILED. Unaligned 64-bit libraries:", file=sys.stderr)
    for name, align in bad:
        print(f"  {name}  PT_LOAD align={align} (need >= {ALIGN_16KB})", file=sys.stderr)
    print(
        "Play will report 'Does not support 16 KB' and Android 15+ installs can fail.",
        file=sys.stderr,
    )
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("aab", type=Path, help="Path to app-release.aab")
    args = parser.parse_args()
    return check_aab(args.aab)


if __name__ == "__main__":
    sys.exit(main())
