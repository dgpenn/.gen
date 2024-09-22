#!/usr/bin/env bash
#
# sets up some very simple iptables rules according to wiki
# ssh (22) and http(s) (80,443) are opened by default
#
# refs:
# - https://wiki.archlinux.org/title/simple_stateful_firewall
#
# todo:
# - potentially modify for iptables-nft or other firewall
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="iptables"

function configure_iptables {

$LOG -i "Installing packages"
pacman-need

$LOG -i "Wrting iptables rules"
cat <<-EOF > /etc/iptables/iptables.rules
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [85:12184]
:TCP - [0:0]
:UDP - [0:0]
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -p icmp -m icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m conntrack --ctstate NEW -j UDP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j TCP
-A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -j REJECT --reject-with tcp-reset
-A INPUT -j REJECT --reject-with icmp-proto-unreachable
-A TCP -p tcp -m tcp --dport 22 -j ACCEPT
-A TCP -p tcp -m tcp --dport 80 -j ACCEPT
-A TCP -p tcp -m tcp --dport 443 -j ACCEPT
COMMIT
EOF

$LOG -i "Writing ip6tables rules"
cat <<-EOF > /etc/iptables/ip6tables.rules
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [85:12184]
:TCP - [0:0]
:UDP - [0:0]
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -s fe80::/10 -p ipv6-icmp -j ACCEPT
-A INPUT -p udp --sport 547 --dport 546 -j ACCEPT
-A INPUT -p udp -m conntrack --ctstate NEW -j UDP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j TCP
-A INPUT -p udp -j REJECT --reject-with icmp6-adm-prohibited
-A INPUT -p tcp -j REJECT --reject-with tcp-reset
-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
-A INPUT -p ipv6-icmp -m icmp6 --icmpv6-type 128 -m conntrack --ctstate NEW -j ACCEPT
-A TCP -p tcp -m tcp --dport 22 -j ACCEPT
-A TCP -p tcp -m tcp --dport 80 -j ACCEPT
-A TCP -p tcp -m tcp --dport 443 -j ACCEPT
COMMIT
EOF

$LOG -i "Enabling iptables and ip6tables"
systemctl enable iptables
systemctl enable ip6tables

}

require_root
configure_iptables
