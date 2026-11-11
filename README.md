# OpenWrt for Nokia G-1425-MA and G-1426-MA

OpenWrt (snapshot, Linux 6.18) for two Nokia GPON ONTs built on EcoNet SoCs.
The stock firmware stays in the other flash bank as a fallback.

| | G-1425-MA | G-1426-MA |
|---|---|---|
| SoC | EcoNet EN7526GT (EN751221 family), MIPS 34Kc, big-endian | EcoNet EN7528DU, MIPS 1004Kc 2×2 threads, little-endian |
| OpenWrt target | `econet/en751221`, device `nokia_g1425` | `econet/en7528`, device `nokia_g1426ma` |
| Ethernet | 4 × 1 GbE (MT7530) | 4 × 1 GbE (built-in switch), hardware NAT (PPE) |
| Wi-Fi | MT7603E + MT7662E, 802.11ac | MT7915, 802.11ax |
| Stock / OpenWrt bank | A / B | B / A |
| Not supported | GPON | GPON, phone port |

The two models are **different hardware**. Never flash one model's image onto the other.

**Images, install instructions, package feed:**
[zortald/gpon_openwrt_packages](https://github.com/zortald/gpon_openwrt_packages)
([releases](https://github.com/zortald/gpon_openwrt_packages/releases),
[Pages](https://zortald.github.io/gpon_openwrt_packages/)).

## What is in this branch

`main` is OpenWrt `main` plus:

- [openwrt/openwrt#25330](https://github.com/openwrt/openwrt/pull/25330) — EcoNet EN751221 DSA
  switch and SoC PHY support, by Caleb James DeLisle;
- the device support for both ONTs (device trees, partition maps, HDR3 image headers for the
  stock bootloader and updater, sysupgrade, boot confirmation for the dual-bank bootloader,
  overlay in the former stock `/data`, Wi-Fi calibration from the stock config);
- `en75_bmt`: BMT reserve size from the device tree (7 % on the G-1426-MA bootloader);
- `econet-eth` patches for EN7528: RX alignment, TX queue wake, PPE hardware NAT through the
  built-in switch, larger RX ring (upstream: cjdelisle/econet_eth
  [#13](https://github.com/cjdelisle/econet_eth/pull/13),
  [#17](https://github.com/cjdelisle/econet_eth/pull/17),
  [#18](https://github.com/cjdelisle/econet_eth/pull/18));
- build configs of the released images in [`configs/`](configs/) and pinned feeds in
  `feeds.conf.default`.

## Build

    git clone https://github.com/zortald/gpon_openwrt.git && cd gpon_openwrt
    ./scripts/feeds update -a && ./scripts/feeds install -a
    cp configs/nokia_g1426ma.config .config    # or configs/nokia_g1425.config
    make defconfig
    make -j$(nproc)

Run the build as a regular user, not root. Images end up in `bin/targets/econet/<subtarget>/`.
Released images, including the files for the stock web upgrade, are in the
[packages repository](https://github.com/zortald/gpon_openwrt_packages/releases). More notes in
[`configs/README.md`](configs/README.md).

## Upstream

Everything else is [OpenWrt](https://openwrt.org) — see the
[upstream repository](https://github.com/openwrt/openwrt) for its documentation and license
(GPL-2.0, see [COPYING](COPYING)).
