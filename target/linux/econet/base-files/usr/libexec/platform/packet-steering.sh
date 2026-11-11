#!/bin/sh
# Packet steering for the Nokia G-1426-MA (EN7528, 2 cores x 2 threads).
# econet_eth has no checksum/TSO offload and the MT7915 MSI interrupt is
# fixed to CPU0, so the generic algorithm leaves everything on CPU0. Move the
# Ethernet interrupt to CPU2 and spread received packets over CPU0, 1 and 3.
# Called by /etc/init.d/packet_steering with network.globals.packet_steering.

. /lib/functions.sh

if [ "$(board_name)" != nokia,g1426ma ]; then
	exec /usr/libexec/network/packet-steering.uc "$@"
fi

mask=0
irqmask=f
[ "${1:-1}" = 0 ] || { mask=b; irqmask=4; }

irq=$(sed -n "s/^ *\([0-9]*\):.*econet_eth-0.*/\1/p" /proc/interrupts)
[ -n "$irq" ] && echo $irqmask > /proc/irq/$irq/smp_affinity

for q in /sys/class/net/eth0/queues/rx-*/rps_cpus /sys/class/net/wan/queues/rx-*/rps_cpus \
	/sys/class/net/lan*/queues/rx-*/rps_cpus /sys/class/net/br-*/queues/rx-*/rps_cpus; do
	[ -w "$q" ] && echo $mask > "$q"
done
exit 0
