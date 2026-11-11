TRX_ENDIAN := le

define Device/en7528_generic
  DEVICE_VENDOR := EN7528
  DEVICE_MODEL := Generic
  DEVICE_DTS := en7528_generic
endef
TARGET_DEVICES += en7528_generic

define Device/dasan_h660gm-a
  $(call Device/tclinux-ubi)
  DEVICE_VENDOR := DASAN
  DEVICE_MODEL := H660GM-A
  FACTORY_SIZE := 32m
  TRX_MODEL := Dewberry
  DEVICE_PACKAGES := kmod-usb2 kmod-mt7603 kmod-mt7615e kmod-mt7663-firmware-ap
endef

define Device/dasan_h660gm-a-airtel
  $(Device/dasan_h660gm-a)
  DEVICE_VARIANT := Airtel
  DEVICE_DTS := en7528_dasan_h660gm-a-airtel
endef
TARGET_DEVICES += dasan_h660gm-a-airtel

define Device/dasan_h660gm-a-generic
  $(Device/dasan_h660gm-a)
  DEVICE_VARIANT := Generic
  DEVICE_DTS := en7528_dasan_h660gm-a-generic
endef
TARGET_DEVICES += dasan_h660gm-a-generic

define Device/jiofiber_en7528
  $(call Device/tclinux-ubi)
  DEVICE_VENDOR := JioFiber
  FACTORY_SIZE := 40m
  TRX_LOADADDR := 0x80002000
  KERNEL := kernel-bin | append-dtb | tclinux-free-bootbase-jump | lzma | \
    kernel-trx
  DEVICE_PACKAGES := kmod-usb3 kmod-mt7603 kmod-mt7615e kmod-mt7663-firmware-ap
endef

define Device/jiofiber_jcow414
  $(Device/jiofiber_en7528)
  DEVICE_MODEL := JCOW414
  DEVICE_ALT0_VENDOR := JioFiber
  DEVICE_ALT0_MODEL := JCO4032
  DEVICE_DTS := en7528_jiofiber_jcow414
endef
TARGET_DEVICES += jiofiber_jcow414

define Device/jiofiber_jcow407
  $(Device/jiofiber_en7528)
  DEVICE_MODEL := JCOW407
  DEVICE_ALT0_VENDOR := JioFiber
  DEVICE_ALT0_MODEL := JCOW407-IN
  DEVICE_DTS := en7528_jiofiber_jcow407
endef
TARGET_DEVICES += jiofiber_jcow407

# The G-1426-MA bootloader expects the "HDR3" magic; the CRC does not cover it
define Build/tclinux-hdr3
	printf HDR3 | dd of=$@ bs=4 count=1 conv=notrunc 2>/dev/null
endef

define Device/nokia_g1426ma
  $(call Device/tclinux-ubi)
  DEVICE_VENDOR := Nokia
  DEVICE_MODEL := G-1426-MA
  DEVICE_DTS := en7528_nokia_g1426ma
  FACTORY_SIZE := 35328k
  TRX_LOADADDR := 0x80002000
  KERNEL := kernel-bin | append-dtb | tclinux-free-bootbase-jump | lzma | \
    kernel-trx | tclinux-hdr3
  DEVICE_PACKAGES := kmod-usb3 kmod-mt7915e kmod-mt7915-firmware \
    wpad-mbedtls
endef
TARGET_DEVICES += nokia_g1426ma
