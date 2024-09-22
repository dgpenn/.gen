#!/usr/bin/env bash
#
# installs and enables NetworkManager
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="dracut python"

MODULES_BLACKLIST=(
    brltty
)

function configure_dracut {

$LOG -i "Installing packages"
pacman-need

for module in "${MODULES_BLACKLIST[@]}"; do
    $LOG -i "Blacklisting $module"
    mkdir -p /etc/dracut.conf.d/

cat <<-'EOF' > /etc/dracut.conf.d/"no_${module}.conf"
    omit_dracutmodules+=" brltty "
EOF

done

$LOG -i "Running dracut_hooks.py"
if [[ -f dracut_hooks.py ]]; then
    python "$PARENT"/dracut_hooks.py --setup
    python "$PARENT"/dracut_hooks.py -a install-hook
fi

}

require_root
configure_dracut
