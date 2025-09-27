#!/usr/bin/env bash
#
# installs and configures labwc
#
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='wayland xorg-xwayland qt6-wayland qt5-wayland wayland-protocols'

function configure_labwc {

pacman-need

$LOG -i "Writing Service File"
cat <<-EOF > /etc/systemd/system/wayland-compositor.service

[Unit]
After=graphical.target systemd-user-sessions.service modprobe@drm.service
Conflicts=getty@tty1.service

[Service]
User=username
WorkingDirectory=~

PAMName=login
TTYPath=/dev/tty1
UnsetEnvironment=TERM

StandardOutput=journal
ExecStart=/bin/labwc -s gtklock

[Install]
WantedBy=graphical.target

EOF

}

require_root
configure_labwc
