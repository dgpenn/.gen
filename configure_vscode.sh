#!/usr/bin/env bash
#
# installs and configures vscode (official)
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='visual-studio-code-bin glib2 icu69 ttf-iosevka-nerd'

function configure_vscode {

pacman-need

}

require_user
configure_vscode
