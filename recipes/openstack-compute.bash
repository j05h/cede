#!/usr/bin/env bash

set -e

VLAN_INTERFACE=${VLAN_INTERFACE-"eth1"}

if [ ! -f /etc/apt/sources.list.d/nova-core-trunk-maverick.list ]; then
  if [ ! -x ./openstack-repo.bash ]; then
    chmod +x ./openstack-repo.bash
  fi
  ./openstack-repo.bash
fi

apt-get -y update

apt-get -y install vlan nova-compute euca2ools unzip vncviewer

virsh net-destroy default
virsh net-undefine default

service libvirt-bin restart

apt-get -y remove apache2-mpm-worker apache2-utils apache2.2-bin apache2.2-common apache2

apt-get -y upgrade

if [ $(grep -c ${VLAN_INTERFACE} /etc/network/interfaces) -eq 0 ]; then
cat<<EOF>>/etc/network/interfaces

auto ${VLAN_INTERFACE}
iface ${VLAN_INTERFACE} inet manual
up ifconfig ${VLAN_INTERFACE} up
EOF
fi

# service networking restart -- doesn't work, meh :/
/etc/init.d/networking restart

echo "You will need to copy your nova.conf in place, and restart compute"
