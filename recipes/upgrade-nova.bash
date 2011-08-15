#!/usr/bin/env bash

set -e

# This makes a couple of assumptions, but the main one is that your "controller" node
# runs nova-network, nova-api, nova-* that's not nova-compute
# You'll need to modify it if you have a different layout

command="apt-get update && apt-get -y dist-upgrade"
key=""

if [ ! -f $key ] || [ -z $key ]; then
  echo "I couldn't find your key file, have you set it correctly?"
  exit
fi

which nova-manage >> /dev/null
if [ $? == 1 ]; then
  echo "I couldn't find your nova-manage command, this should be run on the controller node"
  exit
fi

# Upgrading nova locally first
echo $command | sh
echo "If nova was upgraded you'll probably want to run nova-manage db sync"

# Then we copy it to all the compute instances and restart compute
for host in $( nova-manage service list | grep compute | awk '{ print $2 }' ); do
  address="${host}"
  ssh -o "StrictHostKeyChecking no" -i $key ${address} "$command"
done
