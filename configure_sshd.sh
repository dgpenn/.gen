#!/usr/bin/env bash
#
# secures and configures sshd
# configures fail2ban and enables it
#
# refs:
# - https://wiki.archlinux.org/title/OpenSSH
# - https://infosec.mozilla.org/guidelines/openssh
# - https://stribika.github.io/2015/01/04/secure-secure-shell.html
# - https://www.ssh-audit.com/hardening_guides.html
# - https://wiki.archlinux.org/title/fail2ban
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="openssh xorg-xauth fail2ban"

function configure_sshd {

$LOG -i "Installing packages"
pacman-need

$LOG -i "Regenerating host keys"
rm /etc/ssh/ssh_host_*
ssh-keygen -q -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

$LOG -i "Removing small moduli"
awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe
mv /etc/ssh/moduli.safe /etc/ssh/moduli

$LOG -i "Writing banner"
cat <<-EOF > /etc/ssh/banner

This is a *private* server.
Please disconnect if you are not authorized.
EOF

$LOG -i "Writing sshd config"
cat <<-EOF > /etc/ssh/sshd_config
Match all

Port 22

AddressFamily inet
ListenAddress 0.0.0.0

PermitRootLogin no

HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com

HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

AuthenticationMethods publickey
PasswordAuthentication no
KbdInteractiveAuthentication no

KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com

AuthorizedKeysFile	.ssh/authorized_keys

LogLevel VERBOSE
SyslogFacility AUTH

PrintMotd no
Banner /etc/ssh/banner

Subsystem sftp  /usr/lib/ssh/sftp-server -f AUTHPRIV -l INFO

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
UsePAM yes

X11Forwarding yes
PrintLastLog no
EOF

$LOG -i "Creating fail2ban log target"
mkdir -p /var/log/fail2ban
cat <<-EOF > /etc/fail2ban/fail2ban.local
[Definition]
logtarget = /var/log/fail2ban/fail2ban.log
EOF

$LOG -i "Hardening fail2ban - creating systemd override"
mkdir -p /etc/systemd/system/fail2ban.service.d
cat <<-EOF > /etc/systemd/system/fail2ban.service.d/override.conf
[Service]
PrivateDevices=yes
PrivateTmp=yes
ProtectHome=read-only
ProtectSystem=strict
ReadWritePaths=-/var/run/fail2ban
ReadWritePaths=-/var/lib/fail2ban
ReadWritePaths=-/var/log/fail2ban
ReadWritePaths=-/var/spool/postfix/maildrop
ReadWritePaths=-/run/xtables.lock
CapabilityBoundingSet=CAP_AUDIT_READ CAP_DAC_READ_SEARCH CAP_NET_ADMIN CAP_NET_RAW
EOF

$LOG -i "Configuring filter to match kernel level log messages"
cat <<-EOF > /etc/fail2ban/filter.d/fwdrop.local
[Definition]
failregex = ^.*DROP_.*SRC=<ADDR> DST=.*$
journalmatch = _TRANSPORT=kernel
EOF

$LOG -i "Configuring ssh jail"
cat <<-EOF > /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true
filter    = sshd
banaction = iptables
backend   = systemd
maxretry  = 5
findtime  = 1d
bantime   = 2w
ignoreip  = 127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
EOF

$LOG -i "Reloading systemd daemons"
systemctl daemon-reload

$LOG -i "Enabling sshd"
systemctl enable sshd

$LOG -i "Enabling fail2ban"
systemctl enable fail2ban

}

require_root
configure_sshd
