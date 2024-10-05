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

shell_integration no-cursor
enable_audio_bell no

font_family IosevkaTermNFM
font_features IosevkaTermNFM +liga
bold_font auto
italic_font auto
bold_italic_font auto
font_size 16.0

foreground #dddddd
background #111111

selection_foreground #000000
selection_background #22aaff
tab_bar_margin_width 5
tab_bar_margin_height 5 5
tab_bar_edge top
tab_bar_style fade
tab_fade 1
tab_bar_min_tabs 0
tab_title_max_length 12
tab_title_template "[{fmt.bold}{index}{fmt.nobold}: {title[:max_title_length]}]"
active_tab_title_template "[{fmt.bold}{index}{fmt.nobold}: {title[:max_title_length]}]"
active_tab_foreground   #00cc00
active_tab_background   #111111
active_tab_font_style normal
inactive_tab_foreground #005500
inactive_tab_background #111111
inactive_tab_font_style normal
tab_bar_background none
tab_bar_margin_color none

remember_window_size  yes
initial_window_width  640
initial_window_height 400
window_margin_width 0
placement_strategy center
draw_minimal_borders yes
window_padding_width 0 10
active_border_color #00ff00
confirm_os_window_close 0

cursor #00cc00
cursor_text_color #000000
cursor_shape block
cursor_shape_unfocused hollow
cursor_blink_interval 0

scrollback_lines 20000
scrollback_indicator_opacity 1.0

mouse_hide_wait 0.5

detect_urls yes
underline_hyperlinks always
url_color #0087bd
url_style dotted
url_prefixes file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh

EOF

}

require_root
configure_kitty
