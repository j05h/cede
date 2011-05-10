#!/usr/bin/env bash

if [ ! -f /etc/apt/sources.list.d/nova-core-trunk-maverick.list ]; then
  ./openstack-repo.bash
fi

apt-get -y update

apt-get -y install vlan

apt-get -y install nova-compute euca2ools unzip

service libvirt-bin restart

echo "You will need to copy your nova.conf in place and restart compute"
