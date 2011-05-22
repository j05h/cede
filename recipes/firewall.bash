#!/usr/bin/env bash

LOOPBACK=lo
INTERNAL=eth0
EXTERNAL=eth1
CONF=/etc/iptables.conf
RESTORE=/etc/network/if-pre-up.d/iptablesload.sh

### Setup NAT;

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#\(net.ipv4.ip_forward=1\)/\1/' /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -o ${EXTERNAL} -j MASQUERADE
iptables -A FORWARD -i ${EXTERNAL} -o ${INTERNAL} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${INTERNAL} -o ${EXTERNAL} -j ACCEPT

### Block all on ${EXTERNAL} but SSH;

iptables -A INPUT -i ${LOOPBACK} -p all -j ACCEPT
iptables -A INPUT -i ${INTERNAL} -p all -j ACCEPT
iptables -A INPUT -i ${EXTERNAL} -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -i ${EXTERNAL} --dport 6670 -j ACCEPT
iptables -P INPUT DROP

### Save;

iptables-save > ${CONF}
chmod 0600 ${CONF}

### Restore;

cat >${RESTORE}<<EOF
#!/bin/sh

iptables-restore < /etc/iptables.conf


exit 0
EOF

chmod 0755 ${RESTORE}

### Secure SSH;

sed -i 's/\(PermitRootLogin\) yes/\1 no/' /etc/ssh/sshd_config
sed -i 's/#\(PasswordAuthentication\) yes/\1 no/' /etc/ssh/sshd_config
sed -i 's/\(Port\) 22/\1 6670/' /etc/ssh/sshd_config

service ssh restart


exit 0
