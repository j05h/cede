#!/usr/bin/env bash

# Source our environment
. .env

for i in $zone1_ip $zone2_ip $zone3_ip; do
  ssh -i $ssh_key $i "apt-get -y install git-core && cd /opt && if [ ! -d cede ]; then git clone git://github.com/retr0h/cede.git; fi && cd cede && git checkout nova-trunk && cd recipes/swift && chmod +x install-swift-node.BETA.bash && ./install-swift-node.BETA.bash"
done
