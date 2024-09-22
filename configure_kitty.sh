#!/usr/bin/env bash
#
# installs and configures kitty
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='kitty python-pygments imagemagick gnu-free-fonts libcanberra ttf-iosevka-nerd'

function configure_kitty() {

pacman-need

$LOG -i "Writing system kitty.conf"
mkdir -p /etc/xdg/kitty
cat <<-EOF > /etc/xdg/kitty/kitty.conf
font_family Iosevka Nerd
bold_font auto
italic_font auto
bold_italic_font auto
font_size 14.0

cursor none
cursor_shape block
shell_integration no-cursor

enable_audio_bell no

window_margin_width 10

tab_bar_edge top
tab_bar_style powerline
tab_powerline_style slanted
tab_bar_min_tabs 0
tab_title_template "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}"

EOF

}

require_root
configure_kitty
