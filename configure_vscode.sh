#!/usr/bin/env bash
#
# installs and configures vscode (official)
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='visual-studio-code-bin glib2 ttf-iosevka-nerd'

function configure_vscode {


mkdir "${HOME}/.config/"

cat <<'EOF' > "${HOME}/.config/code-flags.conf"
--enable-features=WaylandWindowDecorations
--ozone-platform-hint=auto
EOF

pacman-need

}

require_user
configure_vscode

