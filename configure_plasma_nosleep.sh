#!/usr/bin/env bash
#
# configures sddm and plasma-desktop to not lock or display the screensaver
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"

PACKAGES=''

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



configure_sddm
configure_screenlock
configure_screensaver
