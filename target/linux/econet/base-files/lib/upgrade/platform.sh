platform_check_image() {
	local board=$(board_name)

	case "$board" in
	chinamobile,gs3101|\
	dasan,h660gm-a-airtel|\
	dasan,h660gm-a-generic|\
	jiofiber,jcow407|\
	jiofiber,jcow414|\
	nokia,g1426ma)
		return 0
		;;
	nokia,g1425)
		# kernel_slave must start with the HDR3 header, otherwise the
		# bootloader rejects bank B and falls back to stock
		[ "$(tar xOf "$1" sysupgrade-nokia_g1425/kernel 2>/dev/null | \
			dd bs=4 count=1 2>/dev/null)" = 3RDH ] && return 0
		echo "Invalid image: kernel has no HDR3 header"
		return 1
		;;
	esac

	return 1
}

platform_do_upgrade() {
	local board=$(board_name)

	case "$board" in
	chinamobile,gs3101|\
	dasan,h660gm-a-airtel|\
	dasan,h660gm-a-generic|\
	jiofiber,jcow407|\
	jiofiber,jcow414)
		CI_KERNPART="tclinux_kernel"
		nand_do_upgrade "$1"
		;;
	nokia,g1425)
		# bank B only: stock in bank A is never touched
		CI_KERNPART="kernel_slave"
		CI_UBIPART="rootfs_slave"
		CI_DATA_UBIPART="openwrt_data"
		nand_do_upgrade "$1"
		;;
	nokia,g1426ma)
		# bank A only: stock in bank B is never touched
		CI_KERNPART="kernel"
		CI_DATA_UBIPART="openwrt_data"
		nand_do_upgrade "$1"
		;;
	esac
}
