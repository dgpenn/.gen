#!/usr/bin/env bash
#
# installs and configures sudo
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="sudo"

function configure_wheel {

mkdir -p /etc/sudoers.d/

cat <<-EOF > /etc/sudoers.d/wheel
    %wheel ALL=(ALL:ALL) ALL
EOF

cat <<-EOF > /etc/sudoers.d/power
    %wheel ALL = NOPASSWD: /sbin/halt, /sbin/reboot, /sbin/poweroff
EOF

}

require_root
configure_wheel
