#!/usr/bin/env bash

# Setup the repo if it hasn't already been done
if [ ! -f /etc/apt/sources.list.d/nova-core-trunk-maverick.list ]; then
  ./openstack-repo.bash
fi

# Install the packages, do the needful
apt-get -y install nova-network euca2ools unzip dnsmasq

# Be sure ip forwarding is enabled or your VMs won't NAT to the world
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
