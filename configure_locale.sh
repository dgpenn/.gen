#!/usr/bin/env bash
#
# Sets locale-related information
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
GEN_LOCALES="en_US.UTF-8 ja_JP.UTF-8 ko_KR.UTF-8"
LANG_LOCALE="en_US.UTF-8"

# shellcheck disable=SC2068
function configure_locale {

$LOG -i "Writing locale.conf"
cat <<-EOF > /etc/locale.conf
LANG="$LANG_LOCALE"
EOF

for locale in ${GEN_LOCALES[@]}; do
    sed -ie "s/^\#${locale}/${locale}/g" "/etc/locale.gen"
done

locale-gen | $LOG -n locale-gen -x -

}

require_root
configure_locale
