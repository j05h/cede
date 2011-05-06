#!/usr/bin/env bash

INTERNAL=eth0
EXTERNAL=eth1

### Setup NAT;

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o ${INTERNAL} -j MASQUERADE
iptables -A FORWARD -i ${INTERNAL} -o ${INTERNAL} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${EXTERNAL} -o eth0 -j ACCEPT

### Block all on ${EXTERNAL} but SSH;

...

### Hosts file;
