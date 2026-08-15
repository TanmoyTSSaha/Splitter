#!/usr/bin/env python3
"""Synthetic ELF/AAB fixtures for scripts/check-aab-16kb.py."""
from __future__ import annotations

import importlib.util
import struct
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    "check_aab_16kb",
    ROOT / "check-aab-16kb.py",
)
assert _spec is not None and _spec.loader is not None
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)
min_pt_load_align = _mod.min_pt_load_align
find_unaligned_libs = _mod.find_unaligned_libs
ALIGN_16KB = _mod.ALIGN_16KB


def make_elf64(load_align: int) -> bytes:
    header = bytearray(64)
    header[0:4] = b"\x7fELF"
    header[4] = 2
    header[5] = 1
    header[6] = 1
    struct.pack_into("<H", header, 16, 3)
    struct.pack_into("<H", header, 18, 0xB7)
    struct.pack_into("<I", header, 20, 1)
    struct.pack_into("<Q", header, 32, 64)
    struct.pack_into("<H", header, 52, 64)
    struct.pack_into("<H", header, 54, 56)
    struct.pack_into("<H", header, 56, 1)
    phdr = bytearray(56)
    struct.pack_into("<I", phdr, 0, 1)
    struct.pack_into("<Q", phdr, 48, load_align)
    return bytes(header + phdr)


class CheckAab16kbTest(unittest.TestCase):
    def test_detects_4kb_align(self) -> None:
        self.assertEqual(min_pt_load_align(make_elf64(0x1000)), 0x1000)

    def test_accepts_16kb_align(self) -> None:
        self.assertEqual(min_pt_load_align(make_elf64(0x4000)), ALIGN_16KB)

    def test_aab_flags_unaligned_mlkit(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            aab = Path(tmp) / "app-release.aab"
            with zipfile.ZipFile(aab, "w") as zf:
                zf.writestr(
                    "base/lib/arm64-v8a/libmlkit_google_ocr_pipeline.so",
                    make_elf64(0x1000),
                )
            bad = find_unaligned_libs(aab)
            self.assertEqual(len(bad), 1)
            self.assertIn("libmlkit_google_ocr_pipeline.so", bad[0][0])
            self.assertEqual(bad[0][1], 0x1000)

    def test_aab_ok_when_aligned(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            aab = Path(tmp) / "app-release.aab"
            with zipfile.ZipFile(aab, "w") as zf:
                zf.writestr(
                    "base/lib/arm64-v8a/libmlkit_google_ocr_pipeline.so",
                    make_elf64(0x4000),
                )
            self.assertEqual(find_unaligned_libs(aab), [])


if __name__ == "__main__":
    unittest.main()
