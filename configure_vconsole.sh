#!/usr/bin/env bash
#
# Sets vconsole keymap and font
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="terminus-font"
VKEYMAP="us"
VFONT="ter-u32n"

function configure_vconsole {

pacman-need "$PACKAGES"

$LOG -i "Writing vconsole.conf"
cat <<-EOF > /etc/vconsole.conf
KEYMAP="$VKEYMAP"
FONT="$VFONT"
EOF

}

require_root
configure_vconsole
