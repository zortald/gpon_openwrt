# Build configs: Nokia G-1425-MA and G-1426-MA

Branch `main` of this repository is OpenWrt `main` plus
[openwrt/openwrt#25330](https://github.com/openwrt/openwrt/pull/25330)
(EcoNet DSA, by Caleb James DeLisle) plus the commits for these two GPON
ONTs. Feeds are pinned in `feeds.conf.default`.

The two models are different hardware (big-endian EN7526GT vs
little-endian EN7528DU, different flash layout). Never flash one model's
image onto the other.

    ./scripts/feeds update -a && ./scripts/feeds install -a
    cp configs/nokia_g1426ma.config .config    # or nokia_g1425.config
    make defconfig
    make -j$(nproc)

After any kernel config change, clean the out-of-tree kernel modules
before building the image, or they keep the old `struct module` layout and
fail to load:

    make package/kernel/econet-eth/clean package/kernel/gpio-button-hotplug/clean \
         package/kernel/mac80211/clean package/kernel/mt76/clean

Images, the package feed and install instructions:
https://github.com/zortald/g1425-openwrt-packages
