#!/usr/bin/env bash

set -e

key=""

if [ ! -f $key ]; then
  echo "I couldn't find your key file, have you set it correctly?"
  exit
fi

which nova-manage >> /dev/null
if [ $? == 1 ]; then
  echo "I couldn't find your nova-manage command, this should be run on the controller node"
  exit
fi

# First we restart our local services to make sure the new nova.conf is in effect
echo "Restarting local nova services to make sure the changesd have taken effect"
for i in $( ls /etc/init.d/nova-* | awk -F/ '{ print $NF }' ); do echo $i; service $i restart; done

# Then we copy it to all the compute instances and restart compute
for host in $( nova-manage service list | grep compute | awk '{ print $1 }' ); do
  address="${host}"
  echo "Copying nova.conf to compute node $host and restarting compute..."
  scp -o "StrictHostKeyChecking no" -i $key /etc/nova/nova.conf root@${address}:/etc/nova/nova.conf
  ssh -o "StrictHostKeyChecking no" -i $key root@$address "service nova-compute restart"
done
