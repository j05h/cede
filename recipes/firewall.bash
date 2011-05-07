#!/usr/bin/env bash

INTERNAL=eth0
EXTERNAL=eth1
CONF=/etc/iptables.conf

### Setup NAT;

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#\(net.ipv4.ip_forward=1\)/\1/' /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -o ${EXTERNAL} -j MASQUERADE
iptables -A FORWARD -i ${EXTERNAL} -o ${INTERNAL} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${INTERNAL} -o ${EXTERNAL} -j ACCEPT

iptables-save > ${CONF}
chmod 0600 ${CONF}

### Block all on ${EXTERNAL} but SSH;

#iptables -A INPUT -i lo -p all -j ACCEPT
#iptables -A INPUT -i ${INTERNAL} -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p tcp --tcp-option ! 2 -j REJECT --reject-with tcp-reset
#iptables -A INPUT -p tcp -i ${EXTERNAL} --dport 22 -j ACCEPT
#iptables -P INPUT DROP
