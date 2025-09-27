#!/usr/bin/env bash
#
# installs the bare minimum to run plasma-desktop
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"

PACKAGES='plasma-desktop sddm wayland'

function configure_plasma {
pacman-need
}

function configure_sddm {

cat <<-EOF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=ghost
Session=plasma
EOF
}

function configure_screenlock {
cat <<-EOF > ~/.config/kscreenlockerrc
[Daemon]
RequirePassword=false
Timeout=-1
EOF
}

function configure_screensaver {
cat <<-EOF > ~/.config/kscreensaverrc
[Daemon]
Autolock=false
EOF
}

if [[ $EUID -eq 0 ]]; then
    configure_plasma
else
    configure_sddm
    configure_screenlock
    configure_screensaver
fi
