#!/usr/bin/env python3
"""Prepend the Nokia G-1425-MA *China Mobile (CMCC)* HDR3 header to the kernel.

The CMCC variant differs from the standard G-1425-MA (g1425-hdr3.py):
  * on-flash magic is the bytes "HDR3" (48 44 52 33), NOT "3RDH";
  * all integer fields are LITTLE-endian (stock crc 0xda071449 is stored
    49 14 07 da);
  * the bank-B kernel mtd (kernel_slave) is only 0x240000 (2.25 MiB), vs
    0x300000 on the standard unit.

Header layout (verified against stock 3FE49218IJHL18 on a live unit):
  0x00  "HDR3"
  0x04  header_len   = 0x100            (u32 LE)
  0x08  total_len    = 0x100 + klen + rlen
  0x0c  crc32        = JAMCRC(kernel+rootfs) = ~crc32(payload)
  0x10  version string (ASCII)
  0x50  kernel_len   (u32 LE)
  0x54  rootfs_len   (u32 LE)
  0x7c  loadaddr     = 0x80002000       (u32 LE)
  0x80..0xa3  stock multi-section descriptors (uboot/upgrade_tool/framework,
              magic "gbnj" at 0xa0). These point at partitions we do NOT
              overwrite (direct dd to kernel_slave/rootfs_slave only), so by
              default we SPLICE them verbatim from the saved stock header to
              keep whatever the bootloader may check valid. Pass --zero-extra
              to zero 0x58..0xff instead (standard-OpenWrt style) if a test
              boot shows the extra fields must be absent.

Like g1425-hdr3.py, only header+kernel is written here; the rootfs (UBI) is
dd'd to rootfs_slave separately, and the bootloader reads it from that
partition offset (confirmed: stock bank A kernel does NOT fill its partition
and rootfs still loads from the fixed rootfs offset).

usage: g1425ma-cmcc-hdr3.py kernel rootfs out [--zero-extra]
"""
import os
import struct
import sys
import zlib

KERNEL_MAX = 0x240000 - 0x100   # header + kernel must fit the 2.25 MiB kernel mtd
LOADADDR = 0x80002000
STOCK_HDR = os.path.join(os.path.dirname(__file__), "g1425ma-cmcc-stock-hdr3.bin")

args = [a for a in sys.argv[1:] if not a.startswith("--")]
zero_extra = "--zero-extra" in sys.argv[1:]
kpath, rpath, opath = args[0], args[1], args[2]

kernel = open(kpath, "rb").read()
rootfs = open(rpath, "rb").read()
if len(kernel) > KERNEL_MAX:
    sys.exit(f"kernel too big: {len(kernel):#x} > {KERNEL_MAX:#x} "
             f"(over by {len(kernel) - KERNEL_MAX} bytes) — trim the kernel config")

# start from the stock header so the 0x80.. multi-section descriptors survive
if not zero_extra and os.path.exists(STOCK_HDR):
    hdr = bytearray(open(STOCK_HDR, "rb").read()[:0x100].ljust(0x100, b"\0"))
else:
    hdr = bytearray(0x100)
    struct.pack_into("<I", hdr, 0x7C, LOADADDR)

payload = kernel + rootfs
hdr[0x00:0x04] = b"HDR3"
struct.pack_into("<I", hdr, 0x04, 0x100)
struct.pack_into("<I", hdr, 0x08, 0x100 + len(payload))
struct.pack_into("<I", hdr, 0x0C, zlib.crc32(payload) ^ 0xFFFFFFFF)
hdr[0x10:0x20] = b"OpenWrt".ljust(0x10, b"\0")
struct.pack_into("<I", hdr, 0x50, len(kernel))
struct.pack_into("<I", hdr, 0x54, len(rootfs))
struct.pack_into("<I", hdr, 0x7C, LOADADDR)

open(opath, "wb").write(bytes(hdr) + kernel)
