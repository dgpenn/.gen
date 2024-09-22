#!/usr/bin/env bash
#
# installs and configures beets
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='beets bash-completion chromaprint ffmpeg gst-plugins-bad gst-plugins-good gst-plugins-ugly gst-libav gst-python imagemagick python-beautifulsoup4 python-discogs-client python-flask python-gobject python-mpd2 python-pyacoustid python-pylast python-requests python-requests-oauthlib python-xdg'

function configure_beets {

pacman-need

# $LOG -i "Writing config.yaml"
# mkdir -p "${HOME}/.config/beets"
# cat <<-'EOF' > "${HOME}/.config/beets/config.yaml"
#
# EOF

}

require_root
configure_beets
