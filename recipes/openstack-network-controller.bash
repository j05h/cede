#!/usr/bin/env bash

if [ ! -f /etc/apt/sources.list.d/nova-core-trunk-maverick.list ]; then
  ./openstack-repo.bash
fi


apt-get -y install nova-network euca2ools unzip
