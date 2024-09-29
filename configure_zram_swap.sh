#!/usr/bin/env bash
#
# crates zram swap device
#
# refs:
# - https://github.com/systemd/zram-generator
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='zram-generator'

function configure_zram_swap {

pacman-need

$LOG -i "Creating zram swap"
mkdir -p /etc/systemd/
cat <<-EOF > /etc/systemd/zram-generator.conf
[zram0]
EOF

$LOG -i "Reloading systemd daemons"
systemctl daemon-reload

$LOG -i "Enabling zram generator"
$LOG -w "Enable will fail under chroot!"
systemctl start /dev/zram0

$LOG -i "Call zramctl to verify creation of zram device"
}

require_root
configure_zram_swap
