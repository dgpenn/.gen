#!/usr/bin/env bash
#
# installs and configures gpg and yubikey-related software
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='gnupg pcsclite ccid yubikey-personalization'

function install_gpg_yubikey() {

pacman-need

}

function configure_gpg() {

mkdir ~/.gnupg
$LOG -i "Writing user gpg.conf"
cat <<-EOF > ~/.gnupg/gpg.conf
personal-cipher-preferences AES256 AES192 AES
personal-digest-preferences SHA512 SHA384 SHA256
personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
cert-digest-algo SHA512
s2k-digest-algo SHA512
s2k-cipher-algo AES256
display-charset utf-8
charset utf-8
no-comments
no-emit-version
no-greeting
keyid-format 0xlong
list-options show-uid-validity
verify-options show-uid-validity
with-fingerprint
require-cross-certification
no-symkey-cache
armor
use-agent
throw-keyids
keyserver hkps://keys.openpgp.org
s2k-count 65011712
EOF

cat <<-EOF > ~/.gnupg/scdaemon.conf
disable-ccid
pcsc-shared
EOF

}

if [[ $EUID -eq 0 ]]; then
    require_root
    install_gpg_yubikey
else
    require_user
    configure_gpg
    echo "Delete the ~/.gnupg directory and re-run this script to ensure all old GPG keys are removed."
fi

