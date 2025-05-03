#!/usr/bin/env bash
#
# installs and configures labwc
#
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='labwc gnu-free-fonts swaybg waybar otf-font-awesome usbmuxd'

function configure_labwc {

pacman-need

}

require_root
configure_labwc
