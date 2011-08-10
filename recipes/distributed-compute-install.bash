#!/usr/bin/env bash

command="cd /opt && git clone git://github.com/retr0h/cede.git && cd cede/recipes && chmod +x openstack-repo.bash openstack-compute.bash && ./openstack-compute.bash"
key=""
hosts=""

if [ ! -d "/opt" ]; then
  mkdir -p /opt
fi

for host in $hosts; do
  ssh_command="ssh -i $key root@${host}"
  $ssh_command "$command"
done
