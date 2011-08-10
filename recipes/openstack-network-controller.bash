#!/usr/bin/env bash

set -e

release=$( lsb_release -a 2>&1 | tail -1 | grep Codename | awk '{ print $2 }' )

# Setup the repo if it hasn't already been done
if [ ! -f /etc/apt/sources.list.d/nova-core-trunk-$release.list ]; then
  if [ ! -x ./openstack-repo.bash ]; then
    chmod +x ./openstack-repo.bash
  fi
  ./openstack-repo.bash
fi

# Install the packages, do the needful
apt-get -y install nova-network euca2ools unzip dnsmasq

# Be sure ip forwarding is enabled or your VMs won't NAT to the world
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

# Disable the default dnsmasq daemon from starting
sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/dnsmasq
service dnsmasq stop
