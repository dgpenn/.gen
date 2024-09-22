#!/usr/bin/env bash
#
# configures whipper
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='whipper python-pillow'

function install_whipper {

pacman-need

}

function configure_whipper {

$LOG -i "Writing whipper.conf"
mkdir -p "${HOME}"/.config/whipper
cat <<-EOF > "${HOME}"/.config/whipper/whipper.conf
[main]
path_filter_dot = True
path_filter_posix = True
path_filter_vfat = False
path_filter_whitespace = True
path_filter_printable = True

[musicbrainz]
server = https://musicbrainz.org

[whipper.cd.rip]
unknown = True
output_directory = ~/music
track_template = %%A/%%d/%%t - %%n
disc_template = %%A/%%d/%%A - %%d

[drive:HL-DT-ST%3ABD-RE%20%20BE14NU40%20%3A1.00]
vendor = HL-DT-ST
model = BD-RE  BE14NU40
release = 1.00
defeats_cache = True
read_offset = 6

[drive:PIONEER%20%3ABD-RW%20%20%20BDR-UD03%3A1.11]
vendor = PIONEER
model = BD-RW   BDR-UD03
release = 1.11
defeats_cache = True
read_offset = 667
EOF

$LOG -w "whipper is configured with ~/music as output directory!"

}

if [[ $EUID -eq 0 ]]; then
    # Install under root (or sudo)
    if type whipper > /dev/null 2>&1; then
        $LOG -e "whipper is already installed! Re-run as regular user to configure!"
    else
        install_whipper
    fi
else
    # Configure whipper for regular user
    if type whipper > /dev/null 2>*1; then
        configure_whipper
    else
        $LOG -e "whipper is not installed! Re-run as root to install!"
    fi
fi
