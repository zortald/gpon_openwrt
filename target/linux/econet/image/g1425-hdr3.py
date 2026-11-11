#!/usr/bin/env python3
"""Prepend the Nokia G-1425-MA HDR3 header (big-endian) to the kernel.

Same header as the stock web upgrade image (mk-web-image.py), so the bank-B
kernel partition looks exactly like after a web upgrade: magic 3RDH, hdr_len
0x100, total_len, JAMCRC over kernel + rootfs, kernel_len, rootfs_len,
loadaddr 0x80002000, bytes 0x80..0xff zero.

usage: g1425-hdr3.py kernel rootfs out
"""
import struct
import sys
import zlib

KERNEL_MAX = 0x300000 - 0x100   # header + kernel must fit the 3 MiB kernel mtd
LOADADDR = 0x80002000

kernel = open(sys.argv[1], "rb").read()
rootfs = open(sys.argv[2], "rb").read()
if len(kernel) > KERNEL_MAX:
    sys.exit(f"kernel too big: {len(kernel):#x} > {KERNEL_MAX:#x}")

payload = kernel + rootfs
hdr = bytearray(0x100)
hdr[0x00:0x04] = b"3RDH"
struct.pack_into(">III", hdr, 0x04, 0x100, 0x100 + len(payload),
                 zlib.crc32(payload) ^ 0xFFFFFFFF)
hdr[0x10:0x17] = b"OpenWrt"
struct.pack_into(">II", hdr, 0x50, len(kernel), len(rootfs))
struct.pack_into(">I", hdr, 0x7C, LOADADDR)
open(sys.argv[3], "wb").write(bytes(hdr) + kernel)
