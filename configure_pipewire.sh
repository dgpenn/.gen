#!/usr/bin/env bash
#
# installs and configures pipewire
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='pipewire pipewire-alsa pipewire-jack pipewire-pulse libpulse gst-plugin-pipewire wireplumber'

function configure_pipewire {

pacman-need

$LOG -i "Use wpctl to control wireplumber"

}

require_root
configure_pipewire
